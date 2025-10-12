/* ========== 请求/响应 DTO ========== */

/** 创建自制地图请求 */
export interface CustomMapCreateReq {
  map_name: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min: number;
  x_max: number;
  y_min: number;
  y_max: number;
  center_x: number;
  center_y: number;
  description?: string;
}

/** 更新自制地图请求 */
export interface CustomMapUpdateReq {
  map_name?: string;
  image_base64?: string;
  image_ext?: ".jpg" | ".jpeg" | ".png" | ".gif" | ".webp";
  x_min?: number;
  x_max?: number;
  y_min?: number;
  y_max?: number;
  center_x?: number;
  center_y?: number;
  description?: string;
}

/** 自制地图响应 */
export interface CustomMapResp {
  id: string;
  map_name: string;
  image_path: string;
  image_url: string;
  x_min: number;
  x_max: number;
  y_min: number;
  y_max: number;
  center_x: number;
  center_y: number;
  description: string;
  created_at: string;
  updated_at: string;
}
