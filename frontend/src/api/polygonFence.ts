// src/api/polygonFence.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type {
  PolygonFenceCreateReq,
  PolygonFenceUpdateReq,
  PolygonFenceResp,
  PointCheckReq,
  PointCheckResp,
} from "@/types/polygonFence";

/* ----------------- 常量 ----------------- */
const URLS = {
  polygonFence: "/api/v1/polygon-fence",
  indoor: "/api/v1/polygon-fence/indoor",
  outdoor: "/api/v1/polygon-fence/outdoor",
  checkAll: "/api/v1/polygon-fence/check-all",
  checkIndoorAll: "/api/v1/polygon-fence/check-indoor-all",
  checkIndoorAny: "/api/v1/polygon-fence/check-indoor-any",
  checkOutdoorAll: "/api/v1/polygon-fence/check-outdoor-all",
  checkOutdoorAny: "/api/v1/polygon-fence/check-outdoor-any",
} as const;

/* ----------------- API 方法 ----------------- */

/**
 * 创建多边形围栏
 * @param data 多边形围栏创建请求数据
 */
export async function createPolygonFence(data: PolygonFenceCreateReq) {
  return request.post<ApiResponse<null>>(`${URLS.polygonFence}/`, data);
}

/**
 * 获取多边形围栏列表
 * @param activeOnly 是否只获取激活的围栏（默认false）
 */
export async function listPolygonFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.polygonFence}/?active_only=true` : `${URLS.polygonFence}/`;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}

/**
 * 获取室内围栏列表
 * @param activeOnly 是否只获取激活的围栏（默认false）
 */
export async function listIndoorFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.indoor}?active_only=true` : URLS.indoor;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}

/**
 * 获取室外围栏列表
 * @param activeOnly 是否只获取激活的围栏（默认false）
 */
export async function listOutdoorFences(activeOnly: boolean = false) {
  const url = activeOnly ? `${URLS.outdoor}?active_only=true` : URLS.outdoor;
  return request.get<ApiResponse<PolygonFenceResp[]>>(url);
}

/**
 * 根据 ID 获取单个多边形围栏
 * @param id 围栏 ID
 */
export async function getPolygonFenceByID(id: string) {
  return request.get<ApiResponse<PolygonFenceResp>>(`${URLS.polygonFence}/${id}`);
}

/**
 * 更新多边形围栏
 * @param id 围栏 ID
 * @param data 多边形围栏更新请求数据
 */
export async function updatePolygonFence(id: string, data: PolygonFenceUpdateReq) {
  return request.put<ApiResponse<null>>(`${URLS.polygonFence}/${id}`, data);
}

/**
 * 删除多边形围栏
 * @param id 围栏 ID
 */
export async function deletePolygonFence(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.polygonFence}/${id}`);
}

/**
 * 检查点是否在指定围栏内
 * @param fenceId 围栏 ID
 * @param point 要检查的点坐标
 */
export async function checkPointInFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(`${URLS.polygonFence}/${fenceId}/check`, point);
}

/**
 * 检查点在哪些围栏内
 * @param point 要检查的点坐标
 */
export async function checkPointInAllFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkAll, point);
}

/**
 * 检查点在哪些室内围栏内
 * @param point 要检查的点坐标
 */
export async function checkPointInIndoorFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkIndoorAll, point);
}

/**
 * 检查点是否在任意一个室内围栏内
 * @param point 要检查的点坐标
 */
export async function checkPointInAnyIndoorFence(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkIndoorAny, point);
}

/**
 * 检查点在哪些室外围栏内
 * @param point 要检查的点坐标
 */
export async function checkPointInOutdoorFences(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkOutdoorAll, point);
}

/**
 * 检查点是否在任意一个室外围栏内
 * @param point 要检查的点坐标
 */
export async function checkPointInAnyOutdoorFence(point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(URLS.checkOutdoorAny, point);
}

/**
 * 检查点是否在指定室内围栏内
 * @param fenceId 围栏 ID
 * @param point 要检查的点坐标
 */
export async function checkPointInIndoorFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(
    `${URLS.polygonFence}/${fenceId}/check-indoor`,
    point,
  );
}

/**
 * 检查点是否在指定室外围栏内
 * @param fenceId 围栏 ID
 * @param point 要检查的点坐标
 */
export async function checkPointInOutdoorFence(fenceId: string, point: PointCheckReq) {
  return request.post<ApiResponse<PointCheckResp>>(
    `${URLS.polygonFence}/${fenceId}/check-outdoor`,
    point,
  );
}
