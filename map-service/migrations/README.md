# 数据库迁移脚本

本目录包含数据库迁移脚本，用于更新现有数据库结构。

## 如何使用

### 方式 1：使用 psql 命令行

```bash
# 连接到数据库并执行迁移脚本
psql -h localhost -U postgres -d iot_manager_db -f migrations/001_allow_null_image_path.sql
```

### 方式 2：使用 PostgreSQL 客户端

1. 连接到数据库
2. 打开并执行迁移脚本文件

### 方式 3：在 Docker 容器中执行

```bash
# 如果使用 docker-compose
docker-compose exec postgres psql -U postgres -d iot_manager_db -f /path/to/migrations/001_allow_null_image_path.sql
```

## 迁移脚本列表

### 001_allow_null_image_path.sql

**版本**: v0.0.2  
**日期**: 2025-01-15

**功能**:

- 允许 `custom_maps` 表的 `image_path` 字段为空
- 支持创建不带图片的纯坐标系统地图

**影响**:

- 修改 `custom_maps` 表结构
- 不影响现有数据

**验证**:
执行后可以通过以下 SQL 验证：

```sql
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'custom_maps'
AND column_name = 'image_path';
```

结果应显示 `is_nullable = 'YES'`

## 注意事项

1. **备份**: 在执行任何迁移脚本之前，请先备份数据库
2. **顺序**: 按照脚本编号顺序执行迁移
3. **回滚**: 如需回滚，请参考各脚本的回滚说明
4. **测试**: 在生产环境执行前，请先在测试环境验证

## 回滚方案

如需回滚 001 迁移：

```sql
-- 警告：此操作会失败，如果表中存在 image_path 为 NULL 的记录
ALTER TABLE custom_maps
ALTER COLUMN image_path SET NOT NULL;
```

如果有 NULL 值记录，需要先更新或删除这些记录：

```sql
-- 方案 1：为 NULL 值设置默认路径
UPDATE custom_maps
SET image_path = '/uploads/maps/placeholder.png'
WHERE image_path IS NULL;

-- 方案 2：删除无图片的地图记录
DELETE FROM custom_maps
WHERE image_path IS NULL;

-- 然后再执行回滚
ALTER TABLE custom_maps
ALTER COLUMN image_path SET NOT NULL;
```
