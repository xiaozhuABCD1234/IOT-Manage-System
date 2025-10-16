package service

import (
	"log"
	"time"

	// "IOT-Manage-System/warning-service/model"
	"IOT-Manage-System/warning-service/repo"
)

type DistancePoller struct {
	r    *repo.MarkRepo
	sd   *repo.SafeDist
	dz   *repo.DangerZone
	tick *time.Ticker
	stop chan struct{}
	done chan struct{}
}

func NewDistancePoller(r *repo.MarkRepo, sd *repo.SafeDist, dz *repo.DangerZone) *DistancePoller {
	return &DistancePoller{
		r:    r,
		sd:   sd,
		dz:   dz,
		stop: make(chan struct{}),
		done: make(chan struct{}),
	}
}

func (p *DistancePoller) Start() {
	p.tick = time.NewTicker(time.Second)
	go p.loop()
}

func (p *DistancePoller) Stop() {
	close(p.stop)
	<-p.done
}

func (p *DistancePoller) loop() {
	defer close(p.done)
	defer p.tick.Stop()
	// log.Printf("DistancePoller: dz instance = %p", p.dz)
	for {
		select {
		case <-p.tick.C:
			// 1. 取在线设备
			onlineDeviceIDs, err := p.r.GetOnlineList()
			if err != nil {
				log.Printf("GetOnlineList error: %v", err)
				continue // 出错就跳过，不碰缓存
			}

			// 2. 在API模式下，如果在线设备列表为空，我们跳过轮询
			// 因为API模式下无法获取在线设备列表，距离检查由Locator实时处理
			if len(onlineDeviceIDs) == 0 {
				// log.Printf("[DEBUG] DistancePoller: 在线设备列表为空，跳过轮询（API模式下正常）")
				continue
			}

			// 3. 查距离
			pairs, err := p.r.GetDistanceByDevice(onlineDeviceIDs)
			if err != nil {
				log.Printf("GetDistanceByDevice error: %v", err)
				continue
			}

			maps, err := p.r.GetBatchDangerZoneM(onlineDeviceIDs)
			if err != nil {
				log.Printf("GetBatchDangerZoneM error: %v", err)
				continue
			}

			// 4. 更新内存
			p.sd.SetBatch(pairs)
			// log.Printf("DistancePoller: about to SetBatch dangerZone, online=%v, maps=%d", onlineDeviceIDs, len(maps))
			// log.Printf("maps content: %+v", maps)
			p.dz.SetBatch(maps)
			// log.Printf("DistancePoller: SetBatch done, dangerZone now has %d entries", len(maps))

		case <-p.stop:
			return
		}
	}
}
