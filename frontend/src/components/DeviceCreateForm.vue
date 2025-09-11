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
  persist_mqtt: undefined,
  safe_distance_m: null,
  mark_type_id: undefined,
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
  form.persist_mqtt = undefined;
  form.safe_distance_m = null;
  form.mark_type_id = undefined;
  form.tags = undefined; // 或设为 [] 如果你希望清空标签但保留字段
};
</script>

<template>
  <!-- 类型选择 -->
  <DangerTypeSelect v-model="form.mark_type_id" />
  <p>当前选中的类型 id：{{ form.mark_type_id }}</p>

  <!-- 设备 ID 选择 -->
  <DeviceIDSelect v-model="form.device_id" />
  <p>当前选中的设备 id：{{ form.device_id }}</p>

  <!-- 标记名称 -->
  <div class="my-4">
    <label for="mark-name" class="mb-1 block text-sm font-medium">标记名称</label>
    <Input id="mark-name" v-model="form.mark_name" placeholder="请输入标记名称..." />
  </div>

  <!-- 安全距离（使用 :value + @input 避免 null 类型错误） -->
  <div class="my-4">
    <label for="safe-distance" class="mb-1 block text-sm font-medium"> 安全距离 (米) </label>
    <Input
      id="safe-distance"
      :value="form.safe_distance_m ?? ''"
      type="number"
      step="0.5"
      placeholder="留空表示使用类型默认值"
      @input="
        ($event.target as HTMLInputElement).value === ''
          ? (form.safe_distance_m = null)
          : (form.safe_distance_m = parseFloat(($event.target as HTMLInputElement).value))
      "
    />
    <p class="mt-1 text-xs text-gray-500">留空表示使用该类型的默认安全距离。</p>
  </div>

  <!-- 标签输入 -->
  <div class="my-4">
    <label class="mb-1 block text-sm font-medium">标签</label>
    <TagsInput v-model="form.tags">
      <template v-if="form.tags && form.tags.length > 0">
        <TagsInputItem v-for="tag in form.tags" :key="tag" :value="tag">
          <TagsInputItemText />
          <TagsInputItemDelete />
        </TagsInputItem>
      </template>
      <TagsInputInput placeholder="输入标签后按 Enter 添加" />
    </TagsInput>
  </div>

  <!-- 持久化开关 -->
  <div class="my-4 flex items-center gap-2">
    <Switch v-model:checked="form.persist_mqtt" id="persist-mqtt-switch" />
    <label for="persist-mqtt-switch" class="text-sm font-medium"> 持久化到 MQTT </label>
  </div>

  <!-- 提交按钮 -->
  <Button type="button" @click="handleSubmit" :disabled="!form.device_id || !form.mark_name.trim()">
    创建标记
  </Button>

  <!-- （可选）重置按钮 -->
  <!--
  <button type="button" @click="resetForm" class="ml-2 px-4 py-2 bg-gray-600 text-white rounded">
    重置
  </button>
  -->

  <!-- 调试用：查看当前数据 -->
  <div class="mt-6 hidden rounded border bg-gray-50 p-4">
    <h3 class="mb-2 font-semibold">当前数据 (payload):</h3>
    <pre class="text-xs">{{
      JSON.stringify(
        Object.fromEntries(Object.entries(form).filter(([_, v]) => v !== undefined)),
        null,
        2,
      )
    }}</pre>
  </div>
</template>
