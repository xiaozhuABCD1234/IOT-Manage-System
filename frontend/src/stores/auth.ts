// stores/auth.ts
import { defineStore } from "pinia";
import { ref } from "vue";
import Cookies from "js-cookie";
import { useRouter } from "vue-router";

export const useAuthStore = defineStore("auth", () => {
  const accessToken = ref(Cookies.get("access_token") || null);
  const hadCheckToken = ref(false);
  const router = useRouter();
  // 登录成功后设置 tokens
  const setTokens = (newAccess: string) => {
    accessToken.value = newAccess;
    Cookies.set("access_token", newAccess); // 不设置过期时间
  };

  // 登出清理
  const logout = () => {
    accessToken.value = null;
    Cookies.remove("access_token");
    router.push("/login");
  };

  return {
    accessToken,
    hadCheckToken,
    setTokens,
    logout,
  };
});
