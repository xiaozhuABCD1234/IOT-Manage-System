<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500" title="删除">
        <Trash class="h-4 w-4" />
      </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>确认删除标记对距离？</AlertDialogTitle>
        <AlertDialogDescription>
          你将永久删除标记对 {{ getMarkName(mark1Id) }} 和
          {{ getMarkName(mark2Id) }} 之间的距离设置，此操作无法撤销。
        </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>取消</AlertDialogCancel>
        <AlertDialogAction
          class="bg-red-500 hover:bg-red-600"
          :disabled="deleting"
          @click="handleDelete"
        >
          {{ deleting ? "删除中..." : "确认删除" }}
        </AlertDialogAction>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</template>

<script setup lang="ts">
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { Trash } from "lucide-vue-next";
import { deletePairDistance } from "@/api/mark/pair";
import { getAllMarkIDToName } from "@/api/mark/index";
import { toast } from "vue-sonner";
import { ref, onMounted } from "vue";

const props = defineProps<{
  mark1Id: string;
  mark2Id: string;
}>();

const emit = defineEmits<{
  deleted: [];
}>();

// 标记名称映射
const markNames = ref<Record<string, string>>({});

const deleting = ref(false);

// 获取标记名称
const getMarkName = (markId: string) => {
  return markNames.value[markId] || markId;
};

const handleDelete = async () => {
  if (deleting.value) return;
  deleting.value = true;
  try {
    await deletePairDistance(props.mark1Id, props.mark2Id);
    toast.success("删除成功");
    emit("deleted");
  } catch (error: any) {
    console.error(error);
    // 如果错误已经在 request.ts 中处理过，就不再重复提示
    if (!error._handled) {
      toast.error("删除失败");
    }
  } finally {
    deleting.value = false;
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
