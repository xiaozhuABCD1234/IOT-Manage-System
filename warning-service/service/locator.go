package service

import (
	"log"
	"math"
	"time"

	"github.com/goccy/go-json"

	mqtt "github.com/eclipse/paho.mqtt.golang"
	"gorm.io/gorm"

	"IOT-Manage-System/warning-service/model"
	"IOT-Manage-System/warning-service/repo"
	"IOT-Manage-System/warning-service/utils"
)

// Locator 依赖三个内存表，后续可接口化
type Locator struct {
	MemRepo      *repo.MemRepo
	SafeDist     *repo.SafeDist
	DangerZone   *repo.DangerZone
	MarkRepo     *repo.MarkRepo
	FenceChecker *FenceChecker
}

// NewLocator 工厂
func NewLocator(db *gorm.DB, SafeDist *repo.SafeDist, DangerZone *repo.DangerZone, MarkRepo *repo.MarkRepo, FenceChecker *FenceChecker) *Locator {
	return &Locator{
		MemRepo:      repo.NewMemRepo(),
		SafeDist:     SafeDist,
		DangerZone:   DangerZone,
		MarkRepo:     MarkRepo,
		FenceChecker: FenceChecker,
	}
}

// OnLocMsg 被 main 注册到 MQTT 回调
func (l *Locator) OnLocMsg(c mqtt.Client, m mqtt.Message) {
	var msg model.LocMsg
	if err := json.Unmarshal(m.Payload(), &msg); err != nil {
		log.Println("[WARN] json err:", err)
		return
	}
	if len(msg.Sens) == 0 {
		return
	}

	var rtkS, uwbS *model.Sens
	for i := range msg.Sens {
		switch msg.Sens[i].N {
		case "RTK":
			rtkS = &msg.Sens[i]
		case "UWB":
			uwbS = &msg.Sens[i]
		}
	}

	// 写 RTK
	if rtkS != nil && len(rtkS.V) >= 2 && rtkS.V[0] != 0 && rtkS.V[1] != 0 {
		l.MemRepo.SetRTK(&model.RTKLoc{
			ID:     msg.ID,
			Indoor: uwbS != nil,
			Lon:    rtkS.V[0],
			Lat:    rtkS.V[1],
		})
		log.Printf("[DEBUG] 收到 RTK 定位消息  deviceID=%s  lon=%f  lat=%f", msg.ID, rtkS.V[0], rtkS.V[1])
	}

	// 写 UWB
	if uwbS != nil && len(uwbS.V) >= 2 {
		l.MemRepo.SetUWB(&model.UWBLoc{
			ID: msg.ID,
			X:  uwbS.V[0],
			Y:  uwbS.V[1],
		})
		log.Printf("[DEBUG] 收到 UWB 定位消息  deviceID=%s  x=%f  y=%f", msg.ID, uwbS.V[0], uwbS.V[1])

		// 检查是否在电子围栏内（异步检查，避免阻塞）
		if l.FenceChecker != nil {
			go l.checkFence(msg.ID, uwbS.V[0], uwbS.V[1])
		}
	}

}

func (l *Locator) Online(c mqtt.Client, m mqtt.Message) {
	var msg model.OnlineMsg
	if err := json.Unmarshal(m.Payload(), &msg); err != nil {
		log.Println("[WARN] json err:", err)
		return
	}
	// log.Println("[INFO] 设备在线", msg.ID)
	l.MarkRepo.SetOnline(msg.ID, time.Now())
}

// checkFence 检查设备是否在围栏内
func (l *Locator) checkFence(deviceID string, x, y float64) {
	isInside, err := l.FenceChecker.CheckPoint(deviceID, x, y)
	if err != nil {
		log.Printf("[WARN] 检查围栏失败 deviceID=%s error=%v", deviceID, err)
		return
	}

	// 使用新的持续报警逻辑
	if l.FenceChecker.ShouldSendAlert(deviceID, isInside) {
		if isInside {
			log.Printf("[FENCE_ALERT] 设备 %s 在电子围栏内，发送警报", deviceID)
			SendWarning(deviceID, true)
		} else {
			log.Printf("[FENCE_ALERT] 设备 %s 离开电子围栏，取消警报", deviceID)
			SendWarning(deviceID, false)
		}
	}
}

// func (l *Locator) sendWarningStart(c mqtt.Client, deviceID string) {
// 	tok := c.Publish("warning/"+deviceID, 1, false, "1")
// 	tok.Wait()
// 	if err := tok.Error(); err != nil {
// 		log.Printf("[ERROR] 发布失败: %v", err)
// 	} else {
// 		log.Printf("[DEBUG] 警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
// 	}
// }

// func (l *Locator) sendWarningEnd(c mqtt.Client, deviceID string) {
// 	tok := c.Publish("warning/"+deviceID, 1, false, "0")
// 	tok.Wait()
// 	if err := tok.Error(); err != nil {
// 		log.Printf("[ERROR] 发布失败: %v", err)
// 	} else {
// 		log.Printf("[DEBUG] 解除警报已发送  deviceID=%s  targetTopic=warning/%s", deviceID, deviceID)
// 	}
// }

// func (l *Locator) checkDistance(l1, l2 model.RTKLoc) {
// 	dis := utils.CalculateRTK(l1, l2)
// 	safe_dis := l.SafeDist.Get(l1.ID, l2.ID)
// 	if safe_dis > 0 {
// 		if dis < safe_dis {
// 			for i := 0; i < 2; i++ {
// 				go l.sendWarningStart(utils.MQTTClient, l1.ID)
// 				go l.sendWarningStart(utils.MQTTClient, l2.ID)
// 			}
// 		}
// 	}
// }

func (l *Locator) StartDistanceChecker() {
	go func() {
		ticker := time.NewTicker(200 * time.Millisecond)
		defer ticker.Stop()
		for range ticker.C {
			l.batchCheckRTK()
			l.batchCheckUWB()
		}
	}()
}

func (l *Locator) batchCheckRTK() {
	// 把当前全量 RTK 快照出来
	snapshot := l.MemRepo.RTKSnapshot()
	ids := make([]string, 0, len(snapshot))
	for id := range snapshot {
		ids = append(ids, id)
	}
	for i := 0; i < len(ids); i++ {
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			distance := utils.CalculateRTK(*a, *b)
			log.Printf("[DEBUG] %s间%s距离: %f", a.ID, b.ID, distance)
			safe := l.SafeDist.Get(a.ID, b.ID)
			log.Printf("[DEBUG] %s间%s安全距离: %f", a.ID, b.ID, safe)
			// 优先使用安全距离检查
			if safe > 0 && distance < safe {
				log.Printf("[DEBUG] 设备间距离 小于安全距离  deviceID1=%s  deviceID2=%s  distance=%f  safe_distance=%f", a.ID, b.ID, distance, safe)
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
			}
			// 安全距离未设置时，检查危险区域
			dangerZoneA := l.DangerZone.Get(a.ID)
			dangerZoneB := l.DangerZone.Get(b.ID)
			// 使用两个设备中较大的危险区域作为判断标准
			dangerZone := math.Max(dangerZoneA, dangerZoneB)
			if dangerZone > 0 && distance < dangerZone {
				log.Printf("[DEBUG] 设备间距离 小于危险距离  deviceID1=%s  deviceID2=%s  distance=%f  danger_distance=%f", a.ID, b.ID, distance, dangerZone)
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
			}
		}
	}
}

func (l *Locator) batchCheckUWB() {
	// 把当前全量 UWB 快照出来
	snapshot := l.MemRepo.UWBSnapshot()
	ids := make([]string, 0, len(snapshot))
	for id := range snapshot {
		ids = append(ids, id)
	}
	for i := 0; i < len(ids); i++ {
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			distance := utils.CalculateUWB(*a, *b)
			log.Printf("[DEBUG] %s间%s距离: %f", a.ID, b.ID, distance)
			safe := l.SafeDist.Get(a.ID, b.ID)
			log.Printf("[DEBUG] %s间%s安全距离: %f", a.ID, b.ID, safe)
			// 优先使用安全距离检查
			if safe > 0 && distance < safe {
				log.Printf("[DEBUG] 设备间距离 小于安全距离  deviceID1=%s  deviceID2=%s  distance=%f  safe_distance=%f", a.ID, b.ID, distance, safe)
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
			}
			// 安全距离未设置时，检查危险区域
			// dangerZoneA := l.DangerZone.Get(a.ID)
			dangerZoneA, _ := l.MarkRepo.GetDangerZoneM(a.ID)
			dangerZoneB := l.DangerZone.Get(b.ID)
			// 使用两个设备中较大的危险区域作为判断标准
			dangerZone := math.Max(dangerZoneA, dangerZoneB)
			if dangerZone > 0 && distance < dangerZone {
				log.Printf("[DEBUG] 设备间距离 小于危险距离  deviceID1=%s  deviceID2=%s  distance=%f  danger_distance=%f", a.ID, b.ID, distance, dangerZone)
				go SendWarning(a.ID, true)
				go SendWarning(b.ID, true)
			}
		}
	}
}
