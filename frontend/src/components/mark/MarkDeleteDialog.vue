<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500" title="删除">
        <Trash class="h-4 w-4" />
      </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>确认删除标记？</AlertDialogTitle>
        <AlertDialogDescription>你将永久删除该标记，此操作无法撤销。</AlertDialogDescription>
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
import { deleteMark } from "@/api/mark";
import { toast } from "vue-sonner";
import { useRouter, useRoute } from "vue-router";
import { ref } from "vue";

const router = useRouter();
const route = useRoute();

const reloadCurrentPage = () =>
  router.replace({
    path: route.fullPath,
    force: true,
    replace: true,
  });
const props = defineProps<{
  id: string;
}>();

const deleting = ref(false);

const handleDelete = async () => {
  if (deleting.value) return;
  deleting.value = true;
  try {
    await deleteMark(props.id);
    await reloadCurrentPage();
    toast.success("删除成功");
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
</script>
