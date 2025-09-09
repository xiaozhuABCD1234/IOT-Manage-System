// ==========================
// MarkType
// ==========================
export interface MarkTypeRequest {
  type_name: string | null; // required, max 255
  default_safe_distance_m?: number | null; // optional, default null
}

export interface MarkTypeResponse {
  id: number;
  type_name: string;
  default_safe_distance_m: number;
}

// ==========================
// MarkTag
// ==========================
export interface MarkTagRequest {
  tag_name: string; // required, max 255
}

export interface MarkTagResponse {
  id: number;
  tag_name: string;
}

// ==========================
// Mark
// ==========================

/** 创建/更新时共用字段 */
export interface MarkCreateRequest {
  device_id: string; // required
  mark_name: string; // required
  mqtt_topic?: string[]; // 不传表示空数组
  persist_mqtt?: boolean; // 不传后端给 false
  safe_distance_m?: number | null; // 传 null 表示“使用类型默认值”
  mark_type_id?: number; // 不传后端给 1
  tags?: string[]; // 不传表示空数组
}

/** 仅更新用：所有字段可选；传 null/undefined 表示不修改，传空数组表示清空 */
export interface MarkUpdateRequest {
  device_id?: string;
  mark_name?: string;
  mqtt_topic?: string[];
  persist_mqtt?: boolean;
  safe_distance_m?: number;
  mark_type_id?: number;
  /** 传 null/undefined 表示不改；传空数组表示清空 */
  tags?: string[] | null;
}

/** 返回给前端的完整结构 */
export interface MarkResponse {
  id: string;
  device_id: string;
  mark_name: string;
  mqtt_topic: string[];
  persist_mqtt: boolean;
  safe_distance_m: number | null;
  mark_type: MarkTypeResponse | null;
  tags: MarkTagResponse[];
  created_at: string; // ISO 8601 时间字符串
  updated_at: string;
  last_online_at: string | null;
}
