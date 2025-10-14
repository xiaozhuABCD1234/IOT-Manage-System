<script setup lang="ts">
import { ref, onMounted } from "vue";
import { useRouter } from "vue-router";
import { getMe } from "@/api/user";
import type { User } from "@/api/user";
import { UserRoundPen } from "lucide-vue-next";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Sheet,
  SheetContent,
  SheetDescription,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";

const user = ref<User | null>(null);
const loading = ref(true);
const router = useRouter();

async function fetchCurrentUser(): Promise<User | null> {
  try {
    const { data } = await getMe();
    return data.data || null; // 真正的 User 对象
  } catch (err) {
    console.error("获取当前用户信息失败", err);
    // 这里可以统一跳转到登录页，也可以把错误继续向上抛
    router.replace("/login");
    return null;
  }
}
onMounted(async () => {
  user.value = await fetchCurrentUser();
  loading.value = false;
});
</script>

<template>
  <div class="flex h-full w-full items-center justify-center">
    <Card class="w-md">
      <CardHeader>
        <CardTitle class="text-2xl">你好！{{ user?.username }}</CardTitle>
        <CardDescription>点击下方可以修改用户信息</CardDescription>
      </CardHeader>
      <CardContent class="grid gap-4">
        <!-- 用户名 -->
        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> ID </Label>
          <Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground text-sm">{{ user?.id }}</p>
        </div>

        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> 用户名 </Label><Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground">{{ user?.username }}</p>
        </div>

        <!-- 用户类型 -->
        <div class="flex items-center justify-between gap-4">
          <Label class="text-lg"> 用户类型 </Label><Skeleton v-if="loading" class="h-6 w-24" />
          <p v-else class="text-muted-foreground">{{ user?.user_type }}</p>
        </div>
      </CardContent>
      <CardFooter>
        <Sheet>
          <SheetTrigger
            ><Button class="w-full">
              <UserRoundPen class="mr-2 h-4 w-4" /> 修改
            </Button></SheetTrigger
          >
          <SheetContent side="bottom">
            <SheetHeader>
              <SheetTitle>修改用户信息</SheetTitle>
              <SheetDescription> 在这里修改你的信息，为空则不修改 </SheetDescription>
            </SheetHeader>
            <div class="flex h-full w-full items-center justify-center">
              <div class="flex flex-col gap-4 py-4 md:w-1/2">
                <!-- 用户名 -->
                <div class="flex items-center gap-4">
                  <Label for="username" class="w-20 shrink-0 text-right">用户名</Label>
                  <Input id="username" class="flex-1" type="text" placeholder="请输入新用户名" />
                </div>

                <!-- 密码 -->
                <div class="flex items-center gap-4">
                  <Label for="password" class="w-20 shrink-0 text-right">密码</Label>
                  <Input id="password" class="flex-1" type="password" placeholder="请输入新密码" />
                </div>
                <div class="flex items-center gap-4">
                  <Label for="password_check" class="w-20 shrink-0 text-right">确认密码</Label>
                  <Input
                    id="password_check"
                    class="flex-1"
                    type="password"
                    placeholder="请确认新密码"
                  />
                </div>
              </div>
            </div>

            <SheetFooter>
              <SheetClose as-child class="flex flex-row-reverse items-center justify-start">
                <Button type="submit" class="m-2.5"> 保存修改 </Button>
              </SheetClose>
            </SheetFooter>
          </SheetContent>
        </Sheet>
      </CardFooter>
    </Card>
  </div>
</template>
