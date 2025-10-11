<template>
  <AlertDialog>
    <AlertDialogTrigger as-child>
      <Button variant="outline" size="icon" class="text-red-500"> <Trash /> </Button>
    </AlertDialogTrigger>
    <AlertDialogContent>
      <AlertDialogHeader>
        <AlertDialogTitle>是否确定删除?</AlertDialogTitle>
        <AlertDialogDescription> 你将永久删除该条数据，请确认是否继续。 </AlertDialogDescription>
      </AlertDialogHeader>
      <AlertDialogFooter>
        <AlertDialogCancel>取消</AlertDialogCancel>
        <AlertDialogAction class="bg-red-500" :disabled="deleting" @click="handleDelete">
          {{ deleting ? "删除中..." : "确认" }}
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
  } catch (error) {
    console.error(error);
    toast.error("删除失败");
  } finally {
    deleting.value = false;
  }
};
</script>
