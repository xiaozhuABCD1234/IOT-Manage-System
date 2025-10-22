<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Link2 class="h-5 w-5" />
        点对点距离设置
      </CardTitle>
      <CardDescription>为两个标记之间设置安全距离</CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 第一个标记选择 -->
        <div class="space-y-2">
          <Label for="mark1">第一个标记</Label>
          <Select v-model="formData.mark1_id" :disabled="Object.keys(markOptions).length === 0">
            <SelectTrigger id="mark1">
              <SelectValue
                :placeholder="Object.keys(markOptions).length === 0 ? '暂无数据' : '选择第一个标记'"
              />
            </SelectTrigger>
            <SelectContent>
              <SelectItem v-for="[id, name] in Object.entries(markOptions)" :key="id" :value="id">
                {{ name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <!-- 第二个标记选择 -->
        <div class="space-y-2">
          <Label for="mark2">第二个标记</Label>
          <Select v-model="formData.mark2_id" :disabled="Object.keys(markOptions).length === 0">
            <SelectTrigger id="mark2">
              <SelectValue
                :placeholder="Object.keys(markOptions).length === 0 ? '暂无数据' : '选择第二个标记'"
              />
            </SelectTrigger>
            <SelectContent>
              <SelectItem
                v-for="[id, name] in Object.entries(markOptions)"
                :key="id"
                :value="id"
                :disabled="id === formData.mark1_id"
              >
                {{ name }}
              </SelectItem>
            </SelectContent>
          </Select>
        </div>

        <!-- 距离输入 -->
        <div class="space-y-2">
          <Label for="distance">安全距离（米）</Label>
          <div class="flex items-center gap-2">
            <Input
              id="distance"
              v-model.number="formData.distance"
              type="number"
              min="0"
              step="0.1"
              placeholder="输入距离值"
              class="flex-1"
            />
            <Badge variant="secondary">米</Badge>
          </div>
        </div>

        <!-- 提交按钮 -->
        <div class="flex gap-2">
          <Button type="submit" :disabled="!isFormValid || isSubmitting" class="flex-1">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "设置中..." : "设置距离" }}
          </Button>
          <Button type="button" variant="outline" @click="handleReset">
            <RotateCcw class="mr-2 h-4 w-4" />
            重置
          </Button>
        </div>
      </form>
    </CardContent>
  </Card>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Link2, Save, RotateCcw } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getAllMarkIDToName } from "@/api/mark/index";
import { setPairDistance } from "@/api/mark/pair";
import type { SetPairDistanceRequest } from "@/types/distance";

// 表单数据
const formData = ref<SetPairDistanceRequest>({
  mark1_id: "",
  mark2_id: "",
  distance: 0,
});

// 标记选项
const markOptions = ref<Record<string, string>>({});
const isSubmitting = ref(false);

// 表单验证
const isFormValid = computed(() => {
  return (
    formData.value.mark1_id &&
    formData.value.mark2_id &&
    formData.value.mark1_id !== formData.value.mark2_id &&
    formData.value.distance >= 0
  );
});

// 加载标记数据
const loadMarkOptions = async () => {
  try {
    const response = await getAllMarkIDToName();
    console.log("获取标记列表响应:", response.data);
    // 响应拦截器已经处理了 code 检查，这里直接使用 data
    if (response.data.data) {
      markOptions.value = response.data.data;
    } else {
      console.warn("响应中没有 data 字段:", response.data);
      markOptions.value = {};
    }
  } catch (error: any) {
    console.error("加载标记列表失败:", error);
    // 错误已在拦截器中处理，这里不再重复提示
  }
};

// 提交表单
const handleSubmit = async () => {
  if (!isFormValid.value) return;

  isSubmitting.value = true;
  try {
    const response = await setPairDistance(formData.value);
    // 响应拦截器已经处理了错误，能到这里说明成功
    toast.success("距离设置成功");
    handleReset();
  } catch (error: any) {
    console.error("设置距离失败:", error);
    // 错误已在拦截器中处理，这里不再重复提示
  } finally {
    isSubmitting.value = false;
  }
};

// 重置表单
const handleReset = () => {
  formData.value = {
    mark1_id: "",
    mark2_id: "",
    distance: 0,
  };
};

// 组件挂载时加载数据
onMounted(() => {
  loadMarkOptions();
});
</script>
