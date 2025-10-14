<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Network class="h-5 w-5" />
        组合距离设置
      </CardTitle>
      <CardDescription>为多个标记之间批量设置统一的安全距离</CardDescription>
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 标记多选 -->
        <div class="space-y-2">
          <Label>选择标记（至少2个）</Label>
          <div class="max-h-64 space-y-2 overflow-y-auto rounded-md border p-3">
            <div
              v-if="Object.keys(markOptions).length === 0"
              class="text-muted-foreground py-4 text-center text-sm"
            >
              暂无数据，请检查后端服务
            </div>
            <div
              v-for="[id, name] in Object.entries(markOptions)"
              :key="id"
              class="flex items-center space-x-2"
            >
              <input
                type="checkbox"
                :id="`mark-${id}`"
                :value="id"
                v-model="selectedMarkIds"
                class="h-4 w-4 rounded border-gray-300"
              />
              <Label :for="`mark-${id}`" class="flex-1 cursor-pointer">
                {{ name }}
              </Label>
            </div>
          </div>
          <div class="text-muted-foreground flex items-center gap-2 text-sm">
            <Badge variant="outline"> 已选择: {{ selectedMarkIds.length }} 个标记 </Badge>
          </div>
        </div>

        <!-- 距离输入 -->
        <div class="space-y-2">
          <Label for="distance">统一安全距离（米）</Label>
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
          <p class="text-muted-foreground text-sm">将为所选标记两两之间设置此距离</p>
        </div>

        <!-- 提交按钮 -->
        <div class="flex gap-2">
          <Button type="submit" :disabled="!isFormValid || isSubmitting" class="flex-1">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "设置中..." : "批量设置距离" }}
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
import { Network, Save, RotateCcw } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { getAllMarkIDToName } from "@/api/mark/index";
import { setCombinationsDistance } from "@/api/mark/pair";
import type { SetCombinationsDistanceRequest } from "@/types/distance";

// 表单数据
const formData = ref<{ distance: number }>({
  distance: 0,
});

// 选中的标记ID列表
const selectedMarkIds = ref<string[]>([]);

// 标记选项
const markOptions = ref<Record<string, string>>({});
const isSubmitting = ref(false);

// 表单验证
const isFormValid = computed(() => {
  return selectedMarkIds.value.length >= 2 && formData.value.distance >= 0;
});

// 加载标记数据
const loadMarkOptions = async () => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.success && response.data.data) {
      markOptions.value = response.data.data;
    } else {
      throw new Error(response.data.message || "获取数据失败");
    }
  } catch (error: any) {
    console.error("加载标记列表失败:", error);
    const errorMsg =
      error.response?.data?.message || error.message || "加载标记列表失败，请检查后端服务";
    toast.error(errorMsg, {
      description: "请确保后端 /api/v1/marks/id-to-name 接口正常运行",
    });
  }
};

// 提交表单
const handleSubmit = async () => {
  if (!isFormValid.value) return;

  const requestData: SetCombinationsDistanceRequest = {
    mark_ids: selectedMarkIds.value,
    distance: formData.value.distance,
  };

  isSubmitting.value = true;
  try {
    const response = await setCombinationsDistance(requestData);
    if (response.data.success) {
      toast.success(`成功为 ${selectedMarkIds.value.length} 个标记设置距离`);
      handleReset();
    } else {
      toast.error(response.data.message || "距离设置失败");
    }
  } catch (error: any) {
    console.error("设置距离失败:", error);
    toast.error(error.response?.data?.message || "设置距离失败");
  } finally {
    isSubmitting.value = false;
  }
};

// 重置表单
const handleReset = () => {
  selectedMarkIds.value = [];
  formData.value = {
    distance: 0,
  };
};

// 组件挂载时加载数据
onMounted(() => {
  loadMarkOptions();
});
</script>
