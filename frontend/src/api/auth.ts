// api/auth.ts
import axiosInstance from '@/axios_config'

export interface TokenResponse {
  access_token: string
  token_type: string
}

export const authApi = {
  login: (username: string, password: string) => {
    // 准备表单数据
    const formData = new URLSearchParams()
    formData.append('grant_type', 'password')
    formData.append('username', username)
    formData.append('password', password)
    formData.append('scope', '')
    formData.append('client_id', '')
    formData.append('client_secret', '')
    return axiosInstance.post<TokenResponse>('/api/user/auth/token', formData)
  },
}
