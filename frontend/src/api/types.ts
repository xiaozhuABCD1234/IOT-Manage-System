// src/api/types.ts
/**
 * API 公共类型定义
 */

/** 分页查询参数 */
export interface ListParams {
  page?: number;
  limit?: number;
  preload?: boolean;
}

/** 用户分页查询参数 */
export interface UserListParams {
  page?: number;
  per_page?: number;
}
