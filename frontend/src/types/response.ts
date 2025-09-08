// src/types/response.ts

/** 后端统一返回结构 */
interface ErrorObj {
  code: string;
  message: string;
  details?: unknown;
}

interface PaginationObj {
  currentPage: number;
  totalPages: number;
  totalItems: number;
  itemsPerPage: number;
  has_next: boolean;
  has_prev: boolean;
}

interface ApiResponse<T = unknown> {
  success: boolean;
  data: T;
  message?: string;
  error?: ErrorObj;
  pagination?: PaginationObj;
  timestamp: string;
}

export type { ApiResponse, PaginationObj, ErrorObj };
