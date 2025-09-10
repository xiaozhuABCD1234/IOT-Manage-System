package repo

import (
	"context"

	"go.mongodb.org/mongo-driver/mongo"

	"IOT-Manage-System/mqtt-watch/model"
)

type MongoRepo interface {
	CreateLoc(loc model.DeviceLoc) error
}

type mongoRepo struct {
	coll *mongo.Collection
}

func NewMongoRepo(coll *mongo.Collection) MongoRepo {
	return &mongoRepo{
		coll: coll,
	}
}

func (r *mongoRepo) CreateLoc(loc model.DeviceLoc) error {
	_, err := r.coll.InsertOne(context.TODO(), loc)
	return err
}

// var (
// 	locBuffer   []model.DeviceLoc // 缓存
// 	bufferMux   sync.Mutex        // 保护缓存
// 	batchSize   = 200             // 多少条写一次
// 	flushPeriod = 5 * time.Second // 最长多久写一次
// 	coll        *mongo.Collection // mongo 集合
// )

// func addBuffer(loc model.DeviceLoc) {
// 	bufferMux.Lock()
// 	locBuffer = append(locBuffer, loc)
// 	needFlush := len(locBuffer) >= batchSize
// 	bufferMux.Unlock()

// 	if needFlush {
// 		flush()
// 	}
// }

// func flush() {
// 	bufferMux.Lock()
// 	if len(locBuffer) == 0 {
// 		bufferMux.Unlock()
// 		return
// 	}
// 	batch := make([]interface{}, len(locBuffer))
// 	for i, v := range locBuffer {
// 		batch[i] = v
// 	}
// 	locBuffer = locBuffer[:0] // 清空
// 	bufferMux.Unlock()

// 	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
// 	defer cancel()
// 	if _, err := coll.InsertMany(ctx, batch); err != nil {
// 		log.Printf("[ERROR] insert many err: %v", err)
// 		return
// 	}
// 	log.Printf("[INFO] 插入 %d 条定位", len(batch))
// }

// func timedFlush() {
// 	ticker := time.NewTicker(flushPeriod)
// 	defer ticker.Stop()
// 	for range ticker.C {
// 		flush()
// 	}
// }
