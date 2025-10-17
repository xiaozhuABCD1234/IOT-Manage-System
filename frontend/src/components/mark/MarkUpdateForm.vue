<script setup lang="ts">
import { reactive, watchEffect } from "vue";
import { updateMark } from "@/api/mark";
import type { MarkUpdateRequest, MarkResponse } from "@/types/mark";
import DangerTypeSelect from "@/components/type/TypeSelect.vue";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import { Button } from "@/components/ui/button";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer";
import { toast } from "vue-sonner";
import { useRouter, useRoute } from "vue-router";

const router = useRouter();
const route = useRoute();

const reloadCurrentPage = () =>
  router.replace({
    path: route.fullPath,
    force: true, // Vue-Router 4.2+ 支持
    replace: true, // 不产生新历史记录
  });

/* ==========  props / emit  ========== */
const props = defineProps<{
  mark: MarkResponse;
}>();

/* ==========  表单数据  ========== */
const form = reactive<MarkUpdateRequest>({
  mark_name: props.mark.mark_name,
  persist_mqtt: props.mark.persist_mqtt,
  danger_zone_m: props.mark.danger_zone_m || -1,
  mark_type_id: props.mark.mark_type?.id,
  tags: (props.mark.tags ?? []).map((t) => t.tag_name), // 安全+简洁
});

/* ==========  提交  ========== */
const handleSubmit = async () => {
  if (!form.mark_name?.trim()) {
    toast.error("标记名称不能为空");
    return;
  }

  /* 只提交非 undefined 字段 */
  const payload: MarkUpdateRequest = {};
  Object.entries(form).forEach(([k, v]) => {
    if (v != null) {
      // payload 允许原值类型，不再仅允许 undefined
      (payload as any)[k as keyof MarkUpdateRequest] = v;
    }
  });
  try {
    const { data } = await updateMark(props.mark.id, payload);
    toast.success("标记已更新");
    reloadCurrentPage();
  } catch (e: any) {
  } finally {
  }
};
</script>

<template>
  <Drawer>
    <DrawerTrigger>
      <slot></slot>
    </DrawerTrigger>
    <DrawerContent>
      <DrawerHeader>
        <DrawerTitle>修改标记</DrawerTitle>
        <DrawerDescription>为空，就不修改</DrawerDescription>
      </DrawerHeader>

      <div class="bg-background mx-auto max-w-2xl rounded-xl border p-6 shadow-md">
        <!-- 标记名称 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">标记名称</label>
          <Input v-model="form.mark_name" placeholder="请输入标记名称…" />
        </div>

        <!-- 类型 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">标记类型</label>
          <DangerTypeSelect v-model="form.mark_type_id" />
        </div>

        <!-- 安全距离 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">安全距离（米）</label>
          <Input
            v-model="form.danger_zone_m"
            type="number"
            step="0.1"
            placeholder="留空表示使用类型默认值"
            @input="
              ($event.target as HTMLInputElement).value === ''
                ? undefined
                : (form.danger_zone_m = parseFloat(($event.target as HTMLInputElement).value))
            "
          />
        </div>

        <!-- 标签 -->
        <div class="mb-5">
          <label class="mb-1 block text-sm font-medium">标签</label>
          <TagsInput v-model="form.tags">
            <template v-if="form.tags && form.tags.length">
              <TagsInputItem v-for="tag in form.tags" :key="tag" :value="tag">
                <TagsInputItemText />
                <TagsInputItemDelete />
              </TagsInputItem>
            </template>
            <TagsInputInput placeholder="输入标签后按 Enter 添加" />
          </TagsInput>
          <p class="text-muted-foreground mt-1 text-xs">
            留空表示不改动标签；删除全部后按保存可清空标签。
          </p>
        </div>

        <!-- 持久化 -->
        <div class="mb-6">
          <label class="mb-1 block text-sm font-medium">保存历史数据</label>
          <Switch v-model="mark.persist_mqtt" />
        </div>
      </div>

      <DrawerFooter class="mx-auto flex flex-row justify-between">
        <DrawerClose as-child>
          <Button @click="handleSubmit">修改</Button>
        </DrawerClose>
        <DrawerClose as-child>
          <Button variant="outline"> 取消 </Button>
        </DrawerClose>
      </DrawerFooter>
    </DrawerContent>
  </Drawer>
</template>
