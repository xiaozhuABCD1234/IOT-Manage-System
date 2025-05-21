// api/trajectory.ts
import axiosInstance from '@/axios_config'
import type { AxiosResponse } from 'axios'

export interface IdsResponse {
  data: number[]
  count: number
}

// 更精确的坐标类型定义
export interface PathMini {
  id: number
  path: [number, number][] // 明确表示经纬度元组
}

// 时间参数增加示例说明
export interface TrajectoryParams {
  id: number
  start_time: string // ISO格式，示例："2024-01-01T00:00:00Z"
  end_time: string // ISO格式，示例："2024-01-02T23:59:59Z"
}

export const trajectoryAPI = {
  // 建议使用驼峰式命名
  getIds: (): Promise<AxiosResponse<IdsResponse>> => axiosInstance.get('/api/trajectory/ids'),

  getMiniPath: (params: TrajectoryParams): Promise<AxiosResponse<PathMini[]>> =>
    axiosInstance.get('/api/trajectory/mini', { params }),
}
