-- 迁移脚本：允许 custom_maps 表的 image_path 字段为空
-- 版本：v0.0.2
-- 日期：2025-01-15
-- 说明：此迁移支持创建不带图片的纯坐标系统地图

-- 修改 image_path 字段，允许为空
ALTER TABLE custom_maps 
ALTER COLUMN image_path DROP NOT NULL;

-- 更新字段注释
COMMENT ON COLUMN custom_maps.image_path IS '图片存储路径（可选，允许为空）';

-- 验证修改
SELECT 
    column_name, 
    data_type, 
    is_nullable, 
    column_default
FROM information_schema.columns
WHERE table_name = 'custom_maps' 
AND column_name = 'image_path';

