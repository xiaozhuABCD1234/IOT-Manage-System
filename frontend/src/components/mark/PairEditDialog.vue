<template>
  <Dialog>
    <DialogTrigger as-child>
      <Button variant="outline" size="icon" title="编辑距离">
        <Pencil class="h-4 w-4" />
      </Button>
    </DialogTrigger>
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>编辑标记对距离</DialogTitle>
        <DialogDescription>
          修改标记对 {{ getMarkName(pair.mark1_id) }} 和
          {{ getMarkName(pair.mark2_id) }} 之间的距离设置
        </DialogDescription>
      </DialogHeader>
      <form @submit.prevent="handleSubmit" class="space-y-4">
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
              required
            />
            <Badge variant="secondary">米</Badge>
          </div>
        </div>
        <DialogFooter>
          <DialogClose as-child>
            <Button type="button" variant="outline">取消</Button>
          </DialogClose>
          <Button type="submit" :disabled="!isFormValid || isSubmitting">
            <Save class="mr-2 h-4 w-4" />
            {{ isSubmitting ? "保存中..." : "保存" }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from "vue";
import { Pencil, Save } from "lucide-vue-next";
import { toast } from "vue-sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { setPairDistance } from "@/api/mark/pair";
import { getAllMarkIDToName } from "@/api/mark/index";
import type { PairItem } from "@/types/distance";

const props = defineProps<{
  pair: PairItem;
}>();

const emit = defineEmits<{
  updated: [];
}>();

// 标记名称映射
const markNames = ref<Record<string, string>>({});

// 表单数据
const formData = ref({
  distance: props.pair.distance_m,
});

const isSubmitting = ref(false);

// 获取标记名称
const getMarkName = (markId: string) => {
  return markNames.value[markId] || markId;
};

// 表单验证
const isFormValid = computed(() => {
  return formData.value.distance >= 0;
});

// 提交表单
const handleSubmit = async () => {
  if (!isFormValid.value) return;

  const requestData = {
    mark1_id: props.pair.mark1_id,
    mark2_id: props.pair.mark2_id,
    distance: formData.value.distance,
  };

  isSubmitting.value = true;
  try {
    await setPairDistance(requestData);
    toast.success("距离设置成功");
    emit("updated");
  } catch (error: any) {
    console.error("设置距离失败:", error);
    // 错误已在拦截器中处理，这里不再重复提示
  } finally {
    isSubmitting.value = false;
  }
};

// 加载标记名称映射
const loadMarkNames = async () => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.data) {
      markNames.value = response.data.data;
    }
  } catch (error) {
    console.error("加载标记名称失败:", error);
  }
};

// 组件挂载时加载标记名称
onMounted(() => {
  loadMarkNames();
});
</script>
