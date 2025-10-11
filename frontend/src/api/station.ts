// src/api/station.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { StationCreateReq, StationUpdateReq, StationResp } from "@/types/station";

/* ----------------- 常量 ----------------- */
const URLS = {
  station: "/api/v1/station/",
} as const;

/* ----------------- API 方法 ----------------- */

/**
 * 创建基站
 * @param data 基站创建请求数据
 */
export async function createStation(data: StationCreateReq) {
  return request.post<ApiResponse<StationResp>>(URLS.station, data);
}

/**
 * 获取基站列表（不分页）
 */
export async function listStations() {
  return request.get<ApiResponse<StationResp[]>>(URLS.station);
}

/**
 * 根据 ID 获取单个基站
 * @param id 基站 ID
 */
export async function getStationByID(id: string) {
  return request.get<ApiResponse<StationResp>>(`${URLS.station}${id}`);
}

/**
 * 更新基站
 * @param id 基站 ID
 * @param data 基站更新请求数据
 */
export async function updateStation(id: string, data: StationUpdateReq) {
  return request.put<ApiResponse<StationResp>>(`${URLS.station}${id}`, data);
}

/**
 * 删除基站
 * @param id 基站 ID
 */
export async function deleteStation(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.station}${id}`);
}
