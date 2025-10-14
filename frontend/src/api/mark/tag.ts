// src/api/mark/tag.ts
import request from "@/utils/request";
import type { ApiResponse, PaginatedData } from "@/types/response";
import type { MarkTagRequest, MarkTagResponse, MarkResponse } from "@/types/mark";
import type { ListParams } from "../types";

const URLS = {
  tags: "/api/v1/tags/",
} as const;

/* 创建标签 */
export async function createMarkTag(data: MarkTagRequest) {
  return request.post<ApiResponse<MarkTagResponse>>(URLS.tags, data);
}

/* 标签列表（分页） */
export async function listMarkTags(params: ListParams = {}) {
  return request.get<ApiResponse<PaginatedData<MarkTagResponse>>>(URLS.tags, { params });
}

/* 根据 ID 获取标签 */
export async function getMarkTagByID(tagId: number) {
  return request.get<ApiResponse<MarkTagResponse>>(`${URLS.tags}${tagId}`);
}

/* 根据名称获取标签 */
export async function getMarkTagByName(name: string) {
  return request.get<ApiResponse<MarkTagResponse>>(`${URLS.tags}name/${name}`);
}

/* 获取所有标签 ID 到标签名称的映射 */
export async function getAllTagIDToName() {
  return request.get<ApiResponse<Record<number, string>>>(`${URLS.tags}id-to-name`);
}

/* 更新标签 */
export async function updateMarkTag(tagId: number, data: MarkTagRequest) {
  return request.put<ApiResponse<MarkTagResponse>>(`${URLS.tags}${tagId}`, data);
}

/* 删除标签 */
export async function deleteMarkTag(tagId: number) {
  return request.delete<ApiResponse<null>>(`${URLS.tags}${tagId}`);
}

/* 根据标签 ID 获取标记列表（分页） */
export async function getMarksByTagID(tagId: number, params: ListParams = {}) {
  return request.get<ApiResponse<PaginatedData<MarkResponse>>>(`${URLS.tags}${tagId}/marks`, {
    params,
  });
}

/* 根据标签名称获取标记列表（分页） */
export async function getMarksByTagName(name: string, params: ListParams = {}) {
  return request.get<ApiResponse<PaginatedData<MarkResponse>>>(`${URLS.tags}name/${name}/marks`, {
    params,
  });
}

// 导出类型
export type { ListParams };
