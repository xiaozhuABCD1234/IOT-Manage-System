// ==========================
// MarkType
// ==========================
export interface MarkTypeRequest {
  type_name: string; // required, max 255
}

export interface MarkTypeResponse {
  id: number;
  type_name: string;
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
export interface MarkRequest {
  device_id: string; // required, max 255
  mark_name: string; // required, max 255
  mqtt_topic: string[]; // optional, max 65535
  persist_mqtt?: boolean; // optional, default false
  safe_distance_m?: number; // optional
  mark_type_id?: number; // optional
  tags?: string[]; // optional
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
