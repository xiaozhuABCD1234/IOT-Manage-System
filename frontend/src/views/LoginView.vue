<!-- src/views/LoginView.vue-->
<template>
  <div
    class="flex min-h-screen w-full items-center justify-center bg-gradient-to-br from-blue-50 via-indigo-200 to-blue-400 p-4 dark:from-gray-900 dark:via-gray-800 dark:to-gray-700"
  >
    <div
      class="mb-30 flex w-full max-w-sm flex-col rounded-xl bg-white shadow-2xl md:max-w-2xl md:flex-row dark:bg-gray-800 dark:shadow-2xl dark:shadow-black/40"
    >
      <!-- 左侧图片：桌面端显示，手机端隐藏 -->
      <div
        class="hidden aspect-square w-full items-center justify-center bg-cover bg-center md:flex md:w-1/2"
      >
        <img
          src="@/assets/imgs/login_bg.webp"
          alt="登录配图"
          class="aspect-square h-full w-full rounded-l-xl object-cover"
        />
      </div>

      <!-- 右侧登录表单 -->
      <div class="w-full p-8 md:w-1/2">
        <h1
          class="font-maplemono mb-6 text-center text-2xl font-bold text-gray-800 dark:text-gray-100"
        >
          登录
        </h1>

        <el-form
          ref="loginFormRef"
          :model="form"
          :rules="rules"
          size="large"
          @submit.prevent="onSubmit"
          class="dark"
        >
          <el-form-item prop="username">
            <el-input
              v-model.trim="form.username"
              placeholder="请输入用户名"
              maxlength="32"
              class="font-maplemono"
            />
          </el-form-item>

          <el-form-item prop="password">
            <el-input
              v-model="form.password"
              type="password"
              placeholder="请输入密码"
              show-password
              maxlength="64"
            />
          </el-form-item>

          <el-form-item>
            <el-button
              native-type="submit"
              :loading="loading"
              class="font-maplemono w-full bg-blue-600 text-white hover:bg-blue-700 dark:bg-blue-500 dark:hover:bg-blue-600"
            >
              登录
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { reactive, ref, onMounted } from "vue";
import { ElMessage } from "element-plus";
import type { FormInstance, FormRules } from "element-plus";
import { useRouter } from "vue-router";
import { userApi } from "@/api/user";

const router = useRouter();

// 用 reactive 包装表单数据，el-form 的 model 需要
const form = reactive({
  username: "",
  password: "",
});

const loading = ref(false);
const loginFormRef = ref<FormInstance>();

// 可选的校验规则
const rules: FormRules = {
  username: [{ required: true, message: "请输入用户名", trigger: "blur" }],
  password: [{ required: true, message: "请输入密码", trigger: "blur" }],
};

// 提交逻辑
async function onSubmit() {
  // 如果写了 rules，可以先校验
  await loginFormRef.value?.validate().catch(() => {
    ElMessage.warning("请完善表单");
    return Promise.reject();
  });

  loading.value = true;
  try {
    const { data } = await userApi.login({
      username: form.username,
      password: form.password,
    });
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);

    ElMessage({
      showClose: true,
      message: "登录成功！🥳",
      type: "success",
    });
    console.log("登录成功！");
  } catch (e: unknown) {
    // 已被全局拦截器处理过，就静默返回
    if (e as unknown as { _handled: boolean }) return;

    // 否则兜底处理
    const err = e as { response?: { data?: { detail?: string } } };
    ElMessage({
      showClose: true,
      message: err.response?.data?.detail || "登录失败，请检查账号密码",
      type: "error",
    });
  } finally {
    loading.value = false;
  }
}
onMounted(() => {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  // 或者更彻底地清空：
  // localStorage.clear(); // ⚠️ 注意：这会清除所有本地数据
});
</script>
