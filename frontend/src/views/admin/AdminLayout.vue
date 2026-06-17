<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { userApi } from "@/api";
import { UserType } from "@/api/user";
import AdminSidebar from "@/components/admin/AdminSidebar.vue";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Sun, Moon, UserRound, LogOut, Monitor } from "lucide-vue-next";
import { useColorMode } from "@vueuse/core";
import { toast } from "vue-sonner";

const router = useRouter();
const mode = useColorMode();
const currentUser = ref<{ id: string; username: string; user_type: UserType } | null>(null);
const authorized = ref(false);

onMounted(async () => {
  // 路由守卫已经验证了管理员权限，这里只需要获取用户信息用于显示
  try {
    const res = await userApi.getMe();
    currentUser.value = res.data.data;
    authorized.value = true;
  } catch {
    toast.error("获取用户信息失败");
    router.replace("/login");
  }
});

function handleLogout() {
  localStorage.removeItem("access_token");
  localStorage.removeItem("refresh_token");
  localStorage.removeItem("refresh_token_time");
  localStorage.removeItem("login_token_time");
  router.push("/login");
}
</script>

<template>
  <div v-if="!authorized" class="flex h-screen items-center justify-center">
    <div class="flex flex-col items-center gap-3">
      <Monitor class="h-10 w-10 animate-pulse text-primary" />
      <p class="text-muted-foreground text-sm">加载中...</p>
    </div>
  </div>
  <div v-else class="flex h-screen overflow-hidden">
    <!-- Sidebar -->
    <AdminSidebar />

    <!-- Main content area -->
    <div class="flex flex-1 flex-col overflow-hidden">
      <!-- Top bar -->
      <header
        class="flex h-14 shrink-0 items-center justify-between border-b bg-background px-6"
      >
        <div class="text-lg font-semibold">管理后台</div>
        <div class="flex items-center gap-2">
          <Button
            variant="ghost"
            size="icon"
            @click="mode = mode === 'light' ? 'dark' : 'light'"
          >
            <Sun v-if="mode === 'light'" class="h-5 w-5" />
            <Moon v-else class="h-5 w-5" />
          </Button>

          <DropdownMenu>
            <DropdownMenuTrigger as-child>
              <Button variant="ghost" size="icon">
                <UserRound class="h-5 w-5" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" class="w-48">
              <div class="px-2 py-1.5">
                <p class="text-sm font-medium">{{ currentUser?.username }}</p>
                <p class="text-xs text-muted-foreground">
                  {{ currentUser?.user_type }}
                </p>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem @click="router.push('/profile')">
                <UserRound class="mr-2 h-4 w-4" />
                个人资料
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem class="text-destructive" @click="handleLogout">
                <LogOut class="mr-2 h-4 w-4" />
                退出登录
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </header>

      <!-- Page content -->
      <main class="flex-1 overflow-y-auto bg-background p-6">
        <router-view />
      </main>
    </div>
  </div>
</template>