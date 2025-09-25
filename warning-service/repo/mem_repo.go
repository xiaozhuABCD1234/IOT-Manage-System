package repo

import (
	"log"
	"sync"
	// "time"

	"IOT-Manage-System/warning-service/model"
)

// MemRepo 线程安全内存仓库
type MemRepo struct {
	mtx sync.RWMutex
	rtk map[string]model.RTKLoc
	uwb map[string]model.UWBLoc
}

func NewMemRepo() *MemRepo {
	return &MemRepo{
		rtk: make(map[string]model.RTKLoc),
		uwb: make(map[string]model.UWBLoc),
	}
}

func (m *MemRepo) SetRTK(v *model.RTKLoc) {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.rtk[v.ID] = *v
}

func (m *MemRepo) RTK(id string) *model.RTKLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	v, ok := m.rtk[id]
	if !ok {
		return nil
	}
	return &v
}

// RangeRTK 只读遍历，回调返回 true 继续，false 中止
func (m *MemRepo) RangeRTK(fn func(id string, loc *model.RTKLoc) bool) {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	for k, v := range m.rtk {
		if !fn(k, &v) {
			return
		}
	}
}

func (m *MemRepo) SetUWB(v *model.UWBLoc) {
	m.mtx.Lock()
	defer m.mtx.Unlock()
	m.uwb[v.ID] = *v
}

func (m *MemRepo) UWB(id string) *model.UWBLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	v, ok := m.uwb[id]
	if !ok {
		return nil
	}
	return &v
}

// RTKSnapshot 返回当前 RTK 表的只读快照
func (m *MemRepo) RTKSnapshot() map[string]*model.RTKLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	snap := make(map[string]*model.RTKLoc, len(m.rtk))
	for k, v := range m.rtk {
		vCopy := v // 拷贝一份，防止外部通过指针修改原始值
		snap[k] = &vCopy
	}
	return snap
}

// UWBSnapshot 返回当前 UWB 表的只读快照
func (m *MemRepo) UWBSnapshot() map[string]*model.UWBLoc {
	m.mtx.RLock()
	defer m.mtx.RUnlock()
	snap := make(map[string]*model.UWBLoc, len(m.uwb))
	for k, v := range m.uwb {
		vCopy := v
		snap[k] = &vCopy
	}
	return snap
}

/* ====== SafeDist ====== */

type SafeDist struct {
	m  map[string]float64
	mu sync.RWMutex
}

func NewSafeDist() *SafeDist { return &SafeDist{m: make(map[string]float64)} }

func (s *SafeDist) keyOf(a, b string) string {
	if a < b {
		return a + ":" + b
	}
	return b + ":" + a
}

func (s *SafeDist) Set(a, b string, d float64) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m[s.keyOf(a, b)] = d
}

func (s *SafeDist) Get(a, b string) float64 {
	s.mu.RLock()
	defer s.mu.RUnlock()
	if v, ok := s.m[s.keyOf(a, b)]; ok {
		return v
	}
	return -1
}

func (s *SafeDist) SetBatch(list []model.MarkPairSafeDistance) {
	// 1. 构造新的 map
	newMap := make(map[string]float64, len(list))
	for _, p := range list {
		k := s.keyOf(p.Mark1ID.String(), p.Mark2ID.String())
		newMap[k] = p.DistanceM
	}

	// 2. 整体替换
	s.mu.Lock()
	defer s.mu.Unlock()
	s.m = newMap // 旧 map 交给 GC
}

/* ====== DangerZone ====== */

type DangerZone struct {
	m  map[string]float64
	mu sync.RWMutex
}

func NewDangerZone() *DangerZone { return &DangerZone{m: make(map[string]float64)} }

func (d *DangerZone) Set(id string, r float64) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.m[id] = r
}

func (d *DangerZone) Get(id string) float64 {
	d.mu.RLock()
	defer d.mu.RUnlock()
	if v, ok := d.m[id]; ok {
		return v
	}
	log.Printf("DangerZone.Get(%s) not found", id)
	return -1
}

func (d *DangerZone) SetBatch(m map[string]float64) {
	d.mu.Lock()
	defer d.mu.Unlock()
	d.m = m
}

// type OnlineStatus struct {
// 	m       map[string]bool
// 	lastAct map[string]time.Time
// 	mu      sync.RWMutex
// 	stop    chan struct{}
// }

// // NewOnlineStatus 创建实例并启动后台扫描协程
// // 参数: idle 多久没更新就视为掉线；scan 每隔多久扫描一次
// func NewOnlineStatus(idle, scan time.Duration) *OnlineStatus {
// 	o := &OnlineStatus{
// 		m:       make(map[string]bool),
// 		lastAct: make(map[string]time.Time),
// 		stop:    make(chan struct{}),
// 	}
// 	go o.autoOffline(idle, scan)
// 	return o
// }

// // Set 设置用户在线状态；online=true 时会刷新活跃时间
// func (o *OnlineStatus) Set(id string, online bool) {
// 	o.mu.Lock()
// 	defer o.mu.Unlock()
// 	o.m[id] = online
// 	if online {
// 		o.lastAct[id] = time.Now()
// 	}
// }

// // Get 查询用户是否在线
// func (o *OnlineStatus) Get(id string) bool {
// 	o.mu.RLock()
// 	defer o.mu.RUnlock()
// 	return o.m[id]
// }

// // Close 停掉后台 goroutine，程序退出前调用
// func (o *OnlineStatus) Close() {
// 	close(o.stop)
// }

// // 后台定时扫描：把超时的用户强制置为 offline
// func (o *OnlineStatus) autoOffline(idle, scan time.Duration) {
// 	tick := time.NewTicker(scan)
// 	defer tick.Stop()
// 	for {
// 		select {
// 		case <-tick.C:
// 			now := time.Now()
// 			o.mu.Lock()
// 			for uid, t := range o.lastAct {
// 				if now.Sub(t) > idle && o.m[uid] {
// 					o.m[uid] = false
// 				}
// 			}
// 			o.mu.Unlock()
// 		case <-o.stop:
// 			return
// 		}
// 	}
// }
