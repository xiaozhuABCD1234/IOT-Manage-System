// ==========================
// MarkPair Distance - 标记对距离管理
// ==========================

/** 设置单对标记距离请求 */
export interface SetPairDistanceRequest {
  mark1_id: string; // 第一个标记的 UUID
  mark2_id: string; // 第二个标记的 UUID
  distance: number; // 安全距离（米），必须 >= 0
}

/** 批量设置标记组合距离请求 */
export interface SetCombinationsDistanceRequest {
  mark_ids: string[]; // 标记 UUID 列表，至少 2 个
  distance: number; // 统一的安全距离（米），必须 >= 0
}

/** 笛卡尔积方式设置标记对距离 - 标识类型 */
export type IdentifierKind = "mark" | "tag" | "type";

/** 笛卡尔积方式设置标记对距离 - 标识定义 */
export interface Identifier {
  kind: IdentifierKind;
  mark_id?: string; // 当 kind="mark" 时使用
  tag_id?: number; // 当 kind="tag" 时使用
  type_id?: number; // 当 kind="type" 时使用
}

/** 笛卡尔积方式设置标记对距离请求 */
export interface SetCartesianDistanceRequest {
  first: Identifier; // 第一组标识
  second: Identifier; // 第二组标识
  distance: number; // 安全距离（米），必须 >= 0
}

/** 单对标记距离响应 */
export interface PairDistanceResponse {
  mark1_id: string;
  mark2_id: string;
  distance: number;
}

/** 标记距离映射表响应（key: 标记 ID, value: 距离） */
export type DistanceMapResponse = Record<string, number>;

/** 标记对项 */
export interface PairItem {
  mark1_id: string;
  mark2_id: string;
  distance_m: number;
}
