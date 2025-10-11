/* ========== 请求/响应 DTO ========== */
export interface StationCreateReq {
  station_name: string;
  location_x: number;
  location_y: number;
}

export interface StationUpdateReq {
  station_name?: string;
  location_x?: number;
  location_y?: number;
}

export interface StationResp {
  id: string;
  station_name: string;
  location_x: number;
  location_y: number;
  created_at: string;
  updated_at: string;
}
