package service

import (
	"log"
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
	MemRepo    *repo.MemRepo
	SafeDist   *repo.SafeDist
	DangerZone *repo.DangerZone
	MarkRepo   *repo.MarkRepo
}

// NewLocator 工厂
func NewLocator(db *gorm.DB) *Locator {
	return &Locator{
		MemRepo:    repo.NewMemRepo(),
		SafeDist:   repo.NewSafeDist(),
		DangerZone: repo.NewDangerZone(),
		MarkRepo:   repo.NewMarkRepo(db),
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
		// log.Printf("[DEBUG] 收到 RTK 定位消息  deviceID=%s  lon=%f  lat=%f", msg.ID, rtkS.V[0], rtkS.V[1])
	}

	// 写 UWB
	if uwbS != nil && len(uwbS.V) >= 2 {
		l.MemRepo.SetUWB(&model.UWBLoc{
			ID: msg.ID,
			X:  uwbS.V[0],
			Y:  uwbS.V[1],
		})
		// log.Printf("[DEBUG] 收到 UWB 定位消息  deviceID=%s  x=%f  y=%f", msg.ID, uwbS.V[0], uwbS.V[1])
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
		ticker := time.NewTicker(500 * time.Millisecond)
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
		dangerZone := l.DangerZone.Get(snapshot[ids[i]].ID)
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			safe := l.SafeDist.Get(a.ID, b.ID)
			if safe <= 0 || dangerZone > 0 {
				if utils.CalculateRTK(*a, *b) < dangerZone {
					SendWarning(a.ID, true)
					SendWarning(b.ID, true)
				}
			}
			if utils.CalculateRTK(*a, *b) < safe {
				SendWarning(a.ID, true)
				SendWarning(b.ID, true)
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
		// dangerZone := l.DangerZone.Get(snapshot[ids[i]].ID)
		dangerZone, _ := l.MarkRepo.GetDangerZoneM(snapshot[ids[i]].ID)

		log.Println("dangerZone:", dangerZone)
		for j := i + 1; j < len(ids); j++ {
			a, b := snapshot[ids[i]], snapshot[ids[j]]
			safe := l.SafeDist.Get(a.ID, b.ID)
			log.Printf("safe_distance: %f", safe)
			if safe <= 0 {
				if utils.CalculateUWB(*a, *b) < dangerZone {
					go SendWarning(a.ID, true)
					go SendWarning(b.ID, true)
				}
			} else {
				if utils.CalculateUWB(*a, *b) < safe {
					go SendWarning(a.ID, true)
					go SendWarning(b.ID, true)
					log.Printf("[DEBUG] 设备间距离 小于安全距离  deviceID1=%s  deviceID2=%s  distance=%f  safe_distance=%f", a.ID, b.ID, utils.CalculateUWB(*a, *b), safe)
				}
			}
		}
	}
}
