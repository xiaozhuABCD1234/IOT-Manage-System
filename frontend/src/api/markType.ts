// src/api/markType.ts
import request from "@/utils/request";
import type { ApiResponse } from "@/types/response";
import type { MarkTypeRequest, MarkTypeResponse, MarkResponse } from "@/types/mark";

export interface ListParams {
  page?: number;
  limit?: number;
  preload?: boolean;
}

const URLS = {
  types: "/api/v1/types/",
} as const;

/* 创建类型 */
export async function createMarkType(data: MarkTypeRequest) {
  return request.post<ApiResponse<MarkTypeResponse>>(URLS.types, data);
}

/* 类型列表（分页） */
export async function listMarkTypes(params: ListParams = {}) {
  return request.get<ApiResponse<MarkTypeResponse[]>>(URLS.types, { params });
}

/* 根据 ID 获取类型 */
export async function getMarkTypeByID(typeId: number) {
  return request.get<ApiResponse<MarkTypeResponse>>(`${URLS.types}${typeId}`);
}

/* 根据名称获取类型 */
export async function getMarkTypeByName(name: string) {
  return request.get<ApiResponse<MarkTypeResponse>>(`${URLS.types}/name/${name}`);
}

/* 更新类型 */
export async function updateMarkType(typeId: number, data: MarkTypeRequest) {
  return request.put<ApiResponse<MarkTypeResponse>>(`${URLS.types}/${typeId}`, data);
}

/* 删除类型 */
export async function deleteMarkType(typeId: number) {
  return request.delete<ApiResponse<null>>(`${URLS.types}/${typeId}`);
}

/* 根据类型 ID 获取标记列表（分页） */
export async function getMarksByTypeID(typeId: number, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse[]>>(`${URLS.types}${typeId}/marks`, {
    params,
  });
}

/* 根据类型名称获取标记列表（分页） */
export async function getMarksByTypeName(name: string, params: ListParams = {}) {
  return request.get<ApiResponse<MarkResponse[]>>(`${URLS.types}/name/${name}/marks`, {
    params,
  });
}

export * as markTypeApi from "./markType";
