<!-- src/views/LoginView.vue -->
<template>
  <!-- 全屏渐变背景 -->
  <div
    class="fixed inset-0 z-[999] flex items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-200 to-blue-400 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700"
  >
    <div
      class="flex w-full max-w-sm flex-col rounded-xl bg-white shadow-2xl md:max-w-2xl md:flex-row dark:bg-gray-800 dark:shadow-black/40"
    >
      <!-- 左侧图片：仅桌面显示 -->
      <div class="hidden md:flex md:w-1/2">
        <img
          src="@/assets/imgs/login_bg_slim.webp"
          alt="登录配图"
          class="h-full w-full rounded-l-xl object-cover"
        />
      </div>

      <!-- 右侧登录表单 -->
      <div class="w-full p-8 md:w-1/2">
        <h1 class="font-maplemono text-center text-2xl font-bold text-gray-800 dark:text-gray-100">
          登录
        </h1>

        <!-- 登录表单 -->
        <form @submit.prevent="onSubmit" class="space-y-6">
          <!-- 用户名 -->

          <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            用户名
          </label>
          <Input
            id="username"
            v-model="form.username"
            type="text"
            placeholder="请输入用户名"
            maxlength="32"
            class="font-maplemono"
          />

          <!-- 密码 -->

          <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            密码
          </label>
          <Input
            id="password"
            v-model="form.password"
            type="password"
            placeholder="请输入密码"
            show-password
            maxlength="64"
            class=""
          />

          <!-- 提交按钮 -->
          <Button type="submit" class="w-full" :disabled="loading" :loading="loading">
            {{ loading ? "登录中..." : "登录" }}
          </Button>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from "vue";
import { useRouter } from "vue-router";
import { userApi } from "@/api/user";
import { toast } from "vue-sonner";

// 引入 shadcn-vue 组件（需提前通过 CLI 添加）
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const router = useRouter();

// 表单数据
const form = reactive({
  username: "",
  password: "",
});

const loading = ref(false);

// 校验并提交
async function onSubmit() {
  if (!form.username.trim()) {
    toast.error("请输入用户名", {
      description: "用户名为必填项",
    });
    return;
  }
  if (!form.password) {
    toast.error("请输入密码", {
      description: "密码为必填项",
    });
    return;
  }

  loading.value = true;
  try {
    const { data: resp } = await userApi.login({
      username: form.username,
      password: form.password,
    });

    localStorage.setItem("access_token", resp.data.access_token);
    localStorage.setItem("refresh_token", resp.data.refresh_token);
    localStorage.setItem("access_token_time", Date.now().toString());
    localStorage.setItem("refresh_token_time", Date.now().toString());

    // 成功提示
    // 注意：shadcn-vue 没有内置 Message，可替换为 Toast 或使用第三方如 notivue2 / sonner
    console.log("登录成功！");
    // 成功提示（替换原来的 alert）
    toast.success("登录成功！", {
      description: "欢迎回来，即将跳转...",
      duration: 3000,
    });

    document.title = "智慧监理平台";
    // router.replace("/");
    router.push("/");
  } catch (e: unknown) {
    // 已被拦截器处理
    const handled = (e as unknown as { _handled: boolean })?._handled;
    if (handled) return;

    // 失败提示（替换原来的 alert）
    toast.error("登录失败", {
      description: "登录失败，请检查账号密码",
      duration: 5000,
    });
  } finally {
    loading.value = false;
  }
}

// 初始化钩子
onMounted(() => {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("refresh_token_time");
  localStorage.removeItem("refresh_token_time");

  document.title = "请登录";
});
</script>
