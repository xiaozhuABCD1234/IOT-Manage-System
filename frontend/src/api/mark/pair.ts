// src/api/mark/pair.ts
import request from "@/utils/request";
import type { ApiResponse, PaginatedData } from "@/types/response";
import type {
  SetPairDistanceRequest,
  SetCombinationsDistanceRequest,
  SetCartesianDistanceRequest,
  PairDistanceResponse,
  DistanceMapResponse,
  PairItem,
} from "@/types/distance";

const URLS = {
  pairs: "/api/v1/pairs",
} as const;

/* ================ 分页查询 ================ */

/* 分页获取标记对列表 */
export async function getPairsList(page: number = 1, limit: number = 10) {
  return request.get<ApiResponse<PaginatedData<PairItem>>>(`${URLS.pairs}`, {
    params: { page, limit },
  });
}

/* ================ 设置距离 ================ */

/* 设置单对标记距离 */
export async function setPairDistance(data: SetPairDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/distance`, data);
}

/* 批量设置标记组合距离 */
export async function setCombinationsDistance(data: SetCombinationsDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/combinations`, data);
}

/* 笛卡尔积方式设置标记对距离 */
export async function setCartesianDistance(data: SetCartesianDistanceRequest) {
  return request.post<ApiResponse<null>>(`${URLS.pairs}/cartesian`, data);
}

/* ================ 查询距离 ================ */

/* 查询单对标记距离 */
export async function getPairDistance(mark1Id: string, mark2Id: string) {
  return request.get<ApiResponse<PairDistanceResponse>>(
    `${URLS.pairs}/distance/${mark1Id}/${mark2Id}`,
  );
}

/* 查询某个标记与所有其他标记的距离映射 */
export async function getDistanceMapByMarkId(markId: string) {
  return request.get<ApiResponse<DistanceMapResponse>>(`${URLS.pairs}/distance/map/mark/${markId}`);
}

/* 查询某个设备与所有其他标记的距离映射 */
export async function getDistanceMapByDeviceId(deviceId: string) {
  return request.get<ApiResponse<DistanceMapResponse>>(
    `${URLS.pairs}/distance/map/device/${deviceId}`,
  );
}

/* ================ 删除距离 ================ */

/* 删除单对标记距离 */
export async function deletePairDistance(mark1Id: string, mark2Id: string) {
  return request.delete<ApiResponse<null>>(`${URLS.pairs}/distance/${mark1Id}/${mark2Id}`);
}
