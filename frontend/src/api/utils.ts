// api/utils.ts
import axiosInstance from '@/axios_config'

export const utilsAPI = {
  getColors: (n: number) => axiosInstance.get<string[]>('/api/utils/colors', { params: { n } }),
}
