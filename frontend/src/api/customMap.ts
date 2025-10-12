// src/api/customMap.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { CustomMapCreateReq, CustomMapUpdateReq, CustomMapResp } from "@/types/customMap";

/* ----------------- 常量 ----------------- */
const URLS = {
  customMap: "/api/v1/custom-map/",
  latest: "/api/v1/custom-map/latest",
} as const;

/* ----------------- API 方法 ----------------- */

/**
 * 创建自制地图（上传图片 + 配置）
 * @param data 自制地图创建请求数据
 */
export async function createCustomMap(data: CustomMapCreateReq) {
  return request.post<ApiResponse<null>>(URLS.customMap, data);
}

/**
 * 获取自制地图列表（不分页）
 */
export async function listCustomMaps() {
  return request.get<ApiResponse<CustomMapResp[]>>(URLS.customMap);
}

/**
 * 获取最新的自制地图
 */
export async function getLatestCustomMap() {
  return request.get<ApiResponse<CustomMapResp>>(URLS.latest);
}

/**
 * 根据 ID 获取单个自制地图
 * @param id 地图 ID
 */
export async function getCustomMapByID(id: string) {
  return request.get<ApiResponse<CustomMapResp>>(`${URLS.customMap}${id}`);
}

/**
 * 更新自制地图
 * @param id 地图 ID
 * @param data 自制地图更新请求数据
 */
export async function updateCustomMap(id: string, data: CustomMapUpdateReq) {
  return request.put<ApiResponse<null>>(`${URLS.customMap}${id}`, data);
}

/**
 * 删除自制地图
 * @param id 地图 ID
 */
export async function deleteCustomMap(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.customMap}${id}`);
}
