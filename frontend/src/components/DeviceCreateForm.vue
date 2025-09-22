<script setup lang="ts">
import DangerTypeSelect from "@/components/TypeSelect.vue";
import DeviceIDSelect from "@/components/DeviceIDSelect.vue";
import { Input } from "@/components/ui/input";
import { Switch } from "@/components/ui/switch";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import { Button } from "@/components/ui/button";

import { reactive } from "vue";
import type { MarkCreateRequest } from "@/types/mark";
import { createMark } from "@/api/mark";
import { toast } from "vue-sonner";

// === 表单数据 ===
const form = reactive<MarkCreateRequest>({
  device_id: "",
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: 1,
  tags: undefined,
});

// === 提交处理函数 ===
const handleSubmit = async () => {
  // 🔹 前端基础验证
  if (!form.device_id) {
    toast.error("请选择设备 ID");
    return;
  }
  if (!form.mark_name.trim()) {
    toast.error("请输入有效的标记名称");
    return;
  }

  // 🔹 构造请求体：只包含非 undefined 字段（null 保留）
  const payload = Object.fromEntries(
    Object.entries(form).filter(([_, value]) => value !== undefined),
  ) as unknown as MarkCreateRequest;
  console.log("正在提交:", payload);

  // 🔹 发送请求
  try {
    await createMark(payload);
    toast.success(`标记 "${form.mark_name}" 创建成功！`);

    // 可选：重置表单
    // resetForm();
  } catch (error: any) {
    const msg = error?.response?.data?.message || "创建失败，请稍后重试";
    toast.error(msg);
    console.error("创建标记失败:", error);
  }
};

// === 可选：重置表单 ===
const resetForm = () => {
  form.device_id = "";
  form.mark_name = "";
  form.persist_mqtt = false;
  form.danger_zone_m = null;
  form.mark_type_id = 1;
  form.tags = undefined; // 或设为 [] 如果你希望清空标签但保留字段
};
</script>

<template>
  <div class="bg-background mx-auto max-w-2xl rounded-xl border p-6 shadow-md">
    <h2 class="mb-6 text-lg font-semibold">新建标记</h2>

    <!-- 设备 ID 选择 -->
    <div class="mb-5">
      <label class="mb-1 block text-sm font-medium">设备</label>
      <DeviceIDSelect v-model="form.device_id" />
    </div>

    <!-- 标记名称 -->
    <div class="mb-5">
      <label for="mark-name" class="mb-1 block text-sm font-medium">标记名称</label>
      <Input id="mark-name" v-model="form.mark_name" placeholder="请输入标记名称…" />
    </div>

    <!-- 类型选择 -->
    <div class="mb-5">
      <label class="mb-1 block text-sm font-medium">标记类型</label>
      <DangerTypeSelect v-model="form.mark_type_id" />
    </div>

    <!-- 安全距离 -->
    <div class="mb-5">
      <label for="safe-distance" class="mb-1 block text-sm font-medium"> 安全距离（米） </label>
      <Input
        id="safe-distance"
        :value="form.danger_zone_m ?? ''"
        type="number"
        step="0.1"
        placeholder="留空表示使用类型默认值"
        @input="
          ($event.target as HTMLInputElement).value === ''
            ? (form.danger_zone_m = null)
            : (form.danger_zone_m = parseFloat(($event.target as HTMLInputElement).value))
        "
      />
    </div>

    <!-- 标签输入 -->
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
    </div>

    <!-- 持久化开关 -->
    <div class="mb-6">
      <label for="persist-mqtt-switch" class="text-sm font-medium"> 保存历史轨迹 </label>
      <br />
      <Switch v-model="form.persist_mqtt" />
    </div>

    <!-- 提交按钮 -->
    <div class="flex items-center gap-3">
      <Button
        type="button"
        @click="handleSubmit"
        :disabled="!form.device_id || !form.mark_name.trim()"
      >
        创建标记
      </Button>

      <Button type="button" variant="outline" @click="resetForm"> 重置 </Button>
    </div>

    <!-- 调试信息（可选） -->
    <div class="bg-muted mt-6 hidden rounded-xl border p-4 text-xs">
      <h3 class="mb-2 font-semibold">当前 payload</h3>
      <pre>{{
        JSON.stringify(
          Object.fromEntries(Object.entries(form).filter(([_, v]) => v !== undefined)),
          null,
          2,
        )
      }}</pre>
    </div>
  </div>
</template>
