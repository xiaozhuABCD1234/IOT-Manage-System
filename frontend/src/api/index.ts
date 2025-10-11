// src/api/index.ts
/**
 * API 统一导出入口
 */

// Mark 相关 API
export * as markApi from "./mark";
export * as tagApi from "./mark/tag";
export * as typeApi from "./mark/type";

// 用户 API
export * as userApi from "./user";

// 告警 API
export * as warningApi from "./warning";

// 公共类型
export type { ListParams, UserListParams } from "./types";

