<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Hash class="h-5 w-5" />
            {{ tagInfo.tag_name }}
          </CardTitle>
          <CardDescription>标签 ID: {{ tagInfo.id }}</CardDescription>
        </div>
        <Button variant="outline" size="sm" @click="openEditDialog">
          <Pencil class="h-4 w-4" />
          编辑
        </Button>
      </div>
    </CardHeader>
  </Card>

  <!-- 编辑标签对话框 -->
  <Dialog v-model:open="editDialogOpen">
    <DialogContent class="sm:max-w-[500px]">
      <DialogHeader>
        <DialogTitle>编辑标签</DialogTitle>
        <DialogDescription>修改标签信息</DialogDescription>
      </DialogHeader>

      <form @submit.prevent="handleUpdate">
        <div class="space-y-4 py-4">
          <!-- 标签名称 -->
          <div class="flex flex-col gap-2">
            <Label for="editTagName">标签名称</Label>
            <Input
              id="editTagName"
              v-model="editForm.tag_name"
              placeholder="请输入标签名称"
              :class="{ 'border-destructive': editV$.tag_name.$error }"
            />
            <span v-if="editV$.tag_name.$error" class="text-destructive text-sm">
              {{ editV$.tag_name.$errors[0].$message }}
            </span>
          </div>
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" @click="editDialogOpen = false"> 取消 </Button>
          <Button type="submit" :disabled="isUpdating">
            {{ isUpdating ? "更新中..." : "更新" }}
          </Button>
        </DialogFooter>
      </form>
    </DialogContent>
  </Dialog>
</template>

<script setup lang="ts">
import { reactive, ref } from "vue";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Hash, Pencil } from "lucide-vue-next";
import type { MarkTagRequest, MarkTagResponse } from "@/types/mark";
import { updateMarkTag } from "@/api/mark/tag";
import { toast } from "vue-sonner";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers } from "@vuelidate/validators";

const props = defineProps<{
  tagInfo: MarkTagResponse;
}>();

const emit = defineEmits<{
  updated: [];
}>();

/* 编辑对话框 */
const editDialogOpen = ref(false);
const editForm = reactive({
  tag_name: "",
});

const editRules = {
  tag_name: { required: helpers.withMessage("请输入标签名称", required) },
};

const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);

function openEditDialog() {
  editForm.tag_name = props.tagInfo.tag_name;
  editV$.value.$reset();
  editDialogOpen.value = true;
}

async function handleUpdate() {
  const valid = await editV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (isUpdating.value) return;
  isUpdating.value = true;

  try {
    const payload: MarkTagRequest = {
      tag_name: editForm.tag_name,
    };

    await updateMarkTag(props.tagInfo.id, payload);

    toast.success("标签更新成功");
    editDialogOpen.value = false;
    emit("updated");
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新标签失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
</script>
