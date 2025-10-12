<template>
  <Card>
    <CardHeader>
      <div class="flex items-center justify-between">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Info class="h-5 w-5" />
            {{ typeInfo.type_name }}
          </CardTitle>
          <CardDescription>
            默认安全距离：{{
              typeInfo.default_danger_zone_m === -1 ? "-" : typeInfo.default_danger_zone_m + " m"
            }}
          </CardDescription>
        </div>
        <Button variant="outline" size="sm" @click="openEditDialog">
          <Pencil class="h-4 w-4" />
          编辑
        </Button>
      </div>
    </CardHeader>
  </Card>

  <!-- 编辑类型对话框 -->
  <Dialog v-model:open="editDialogOpen">
    <DialogContent class="sm:max-w-[500px]">
      <DialogHeader>
        <DialogTitle>编辑类型</DialogTitle>
        <DialogDescription>修改类型信息</DialogDescription>
      </DialogHeader>

      <form @submit.prevent="handleUpdate">
        <div class="space-y-4 py-4">
          <!-- 类型名称 -->
          <div class="flex flex-col gap-2">
            <Label for="editTypeName">类型名称</Label>
            <Input
              id="editTypeName"
              v-model="editForm.type_name"
              placeholder="请输入类型名称"
              :class="{ 'border-destructive': editV$.type_name.$error }"
            />
            <span v-if="editV$.type_name.$error" class="text-destructive text-sm">
              {{ editV$.type_name.$errors[0].$message }}
            </span>
          </div>

          <!-- 默认安全距离 -->
          <div class="flex flex-col gap-2">
            <Label for="editDangerZone">默认安全距离（米）</Label>
            <Input
              id="editDangerZone"
              :value="editForm.default_danger_zone_m ?? ''"
              type="number"
              step="0.1"
              placeholder="留空表示不设置默认值"
              @input="
                ($event.target as HTMLInputElement).value === ''
                  ? (editForm.default_danger_zone_m = null)
                  : (editForm.default_danger_zone_m = parseFloat(
                      ($event.target as HTMLInputElement).value,
                    ))
              "
            />
            <span class="text-muted-foreground text-xs"> 设置 -1 表示无默认值 </span>
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
import { Info, Pencil } from "lucide-vue-next";
import type { MarkTypeRequest, MarkTypeResponse } from "@/types/mark";
import { updateMarkType } from "@/api/mark/type";
import { toast } from "vue-sonner";
import { useVuelidate } from "@vuelidate/core";
import { required, helpers } from "@vuelidate/validators";

const props = defineProps<{
  typeInfo: MarkTypeResponse;
}>();

const emit = defineEmits<{
  updated: [];
}>();

/* 编辑对话框 */
const editDialogOpen = ref(false);
const editForm = reactive({
  type_name: "",
  default_danger_zone_m: null as number | null,
});

const editRules = {
  type_name: { required: helpers.withMessage("请输入类型名称", required) },
};

const editV$ = useVuelidate(editRules, editForm);
const isUpdating = ref(false);

function openEditDialog() {
  editForm.type_name = props.typeInfo.type_name;
  editForm.default_danger_zone_m =
    props.typeInfo.default_danger_zone_m === -1 ? null : props.typeInfo.default_danger_zone_m;
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
    const payload: MarkTypeRequest = {
      type_name: editForm.type_name,
      default_danger_zone_m:
        editForm.default_danger_zone_m === null ? -1 : editForm.default_danger_zone_m,
    };

    await updateMarkType(props.typeInfo.id, payload);

    toast.success("类型更新成功");
    editDialogOpen.value = false;
    emit("updated");
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "更新失败";
      toast.error("更新类型失败", { description: errorMsg });
    }
  } finally {
    isUpdating.value = false;
  }
}
</script>
