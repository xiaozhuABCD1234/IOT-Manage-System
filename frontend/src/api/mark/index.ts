// src/api/mark/index.ts
import request from "@/utils/request";
import type { ApiResponse, PaginatedData } from "@/types/response";
import type { MarkCreateRequest, MarkUpdateRequest, MarkResponse } from "@/types/mark";
import type { ListParams } from "../types";

/* ----------------- 常量 ----------------- */
const URLS = {
  marks: "/api/v1/marks/",
  persist: "/api/v1/marks/persist",
  tags: "/api/v1/tags/",
  types: "/api/v1/types/",
} as const;

/* ----------------- API 方法 ----------------- */

/* 创建标记 */
export async function createMark(data: MarkCreateRequest) {
  return request.post<ApiResponse<MarkResponse>>(URLS.marks, data);
}

/* 根据 ID 获取标记 */
export async function getMarkByID(id: string, preload = false) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.marks}/${id}`, {
    params: { preload },
  });
}

/* 根据设备 ID 获取标记 */
export async function getMarkByDeviceID(deviceId: string, preload = false) {
  return request.get<ApiResponse<MarkResponse>>(`${URLS.marks}device/${deviceId}`, {
    params: { preload },
  });
}

/* 获取所有设备 ID 到标记名称的映射 */
export async function getAllDeviceIDToName() {
  return request.get<ApiResponse<Record<string, string>>>(`${URLS.marks}device/id-to-name`);
}

/* 获取所有标记 ID 到标记名称的映射 */
export async function getAllMarkIDToName() {
  return request.get<ApiResponse<Record<string, string>>>(`${URLS.marks}id-to-name`);
}

/* 分页获取标记列表 */
export async function listMarks(params: ListParams = {}) {
  return request.get<ApiResponse<PaginatedData<MarkResponse>>>(URLS.marks, { params });
}

/* 更新标记 */
export async function updateMark(id: string, data: MarkUpdateRequest) {
  return request.put<ApiResponse<MarkResponse>>(`${URLS.marks}${id}`, data);
}

/* 删除标记 */
export async function deleteMark(id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.marks}${id}`);
}

/* 更新标记最后在线时间 */
export async function updateMarkLastOnline(deviceId: string) {
  return request.put<ApiResponse<null>>(`${URLS.marks}device/${deviceId}/last-online`, {});
}

/* 根据设备 ID 查询 PersistMQTT 值 */
export async function getPersistMQTTByDeviceID(deviceId: string) {
  return request.get<ApiResponse<boolean>>(`${URLS.persist}/device/${deviceId}`);
}

/* 根据 PersistMQTT 值分页查询标记 */
export async function getMarksByPersistMQTT(persist: boolean, params: ListParams = {}) {
  return request.get<ApiResponse<PaginatedData<MarkResponse>>>(`${URLS.persist}/list`, {
    params: { persist, ...params },
  });
}

/* 根据 PersistMQTT 值查询所有 DeviceID 列表 */
export async function getDeviceIDsByPersistMQTT(persist: boolean) {
  return request.get<ApiResponse<string[]>>(`${URLS.persist}/device-ids`, {
    params: { persist },
  });
}

// 导出类型
export type { ListParams };
