/* ========== 请求/响应 DTO ========== */

/** 坐标点 */
export interface Point {
  x: number;
  y: number;
}

/** 创建多边形围栏请求 */
export interface PolygonFenceCreateReq {
  is_indoor: boolean;
  fence_name: string;
  points: Point[];
  description?: string;
}

/** 更新多边形围栏请求 */
export interface PolygonFenceUpdateReq {
  is_indoor?: boolean;
  fence_name?: string;
  points?: Point[];
  description?: string;
  is_active?: boolean;
}

/** 多边形围栏响应 */
export interface PolygonFenceResp {
  id: string;
  is_indoor: boolean;
  fence_name: string;
  points: Point[];
  description: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

/** 检查点是否在围栏内的请求 */
export interface PointCheckReq {
  x: number;
  y: number;
}

/** 检查点是否在围栏内的响应 */
export interface PointCheckResp {
  is_inside: boolean;
  fence_id?: string;
  fence_name?: string;
  fence_names?: string[];
}
