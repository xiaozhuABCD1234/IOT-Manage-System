// src/types/response.ts

/** 后端统一返回结构（mark-service 格式）*/
interface ApiResponse<T = unknown> {
  code: number;
  msg: string;
  data: T;
}

/** 分页响应数据结构 */
interface PaginatedData<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}

/** 旧版响应结构 - 兼容其他服务 */
interface LegacyErrorObj {
  code: string;
  message: string;
  details?: unknown;
}

interface LegacyPaginationObj {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  has_next: boolean;
  has_prev: boolean;
}

interface LegacyApiResponse<T = unknown> {
  success: boolean;
  data: T;
  message?: string;
  error?: LegacyErrorObj;
  pagination?: LegacyPaginationObj;
  timestamp: string;
}

export type { ApiResponse, PaginatedData, LegacyApiResponse, LegacyPaginationObj, LegacyErrorObj };
