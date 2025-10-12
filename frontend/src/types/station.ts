/* ========== 请求/响应 DTO ========== */
export interface StationCreateReq {
  station_name: string;
  coordinate_x: number;
  coordinate_y: number;
}

export interface StationUpdateReq {
  station_name?: string;
  coordinate_x?: number;
  coordinate_y?: number;
}

export interface StationResp {
  id: string;
  station_name: string;
  coordinate_x: number;
  coordinate_y: number;
  created_at: string;
  updated_at: string;
}
