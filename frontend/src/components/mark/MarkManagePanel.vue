<!-- src/components/mark/MarkManagePanel.vue -->
<script setup lang="ts">
import { ref, reactive } from "vue";
import { required, helpers } from "@vuelidate/validators";
import useVuelidate from "@vuelidate/core";
import { toast } from "vue-sonner";
import { Plus, Tag } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  TagsInput,
  TagsInputInput,
  TagsInputItem,
  TagsInputItemDelete,
  TagsInputItemText,
} from "@/components/ui/tags-input";
import { createMark, listMarks } from "@/api/mark";
import type { MarkCreateRequest } from "@/types/mark";
import DeviceIDSelect from "@/components/device/DeviceIDSelect.vue";
import TypeSelect from "@/components/type/TypeSelect.vue";
import MarkTablePager from "./MarkTablePager.vue";

/* -------------------------------------------------- */
/* 类型定义                                           */
/* -------------------------------------------------- */
interface CreateFormState {
  device_id: string;
  mark_name: string;
  persist_mqtt: boolean;
  danger_zone_m: number | null;
  mark_type_id: number;
  tags: string[] | undefined;
}

/* -------------------------------------------------- */
/* 标记列表                                           */
/* -------------------------------------------------- */
const tableKey = ref(0);

function refreshTable() {
  tableKey.value++;
}

/* -------------------------------------------------- */
/* 创建标记                                           */
/* -------------------------------------------------- */
const createDialogOpen = ref(false);
const createFormInitial: CreateFormState = {
  device_id: "",
  mark_name: "",
  persist_mqtt: false,
  danger_zone_m: null,
  mark_type_id: 1,
  tags: undefined,
};

const createForm = reactive<CreateFormState>({ ...createFormInitial });

const createRules = {
  device_id: { required: helpers.withMessage("请选择设备ID", required) },
  mark_name: { required: helpers.withMessage("请输入标记名称", required) },
};

const createV$ = useVuelidate(createRules, createForm);
const isCreating = ref(false);

async function handleCreate() {
  const valid = await createV$.value.$validate();
  if (!valid) {
    toast.error("请填写完整的表单信息");
    return;
  }

  if (isCreating.value) return;
  isCreating.value = true;

  try {
    const payload = Object.fromEntries(
      Object.entries(createForm).filter(([_, value]) => value !== undefined),
    ) as unknown as MarkCreateRequest;

    await createMark(payload);

    toast.success("标记创建成功");
    createDialogOpen.value = false;
    Object.assign(createForm, createFormInitial);
    createV$.value.$reset();
    refreshTable();
  } catch (e: any) {
    if (!e._handled) {
      const errorMsg = e.response?.data?.message || e.message || "创建失败";
      toast.error("创建标记失败", { description: errorMsg });
    }
  } finally {
    isCreating.value = false;
  }
}

</script>

<template>
  <div class="flex h-full w-full flex-col gap-4 p-4">
    <!-- 标题和创建按钮 -->
    <Card>
      <CardHeader>
        <div class="flex items-center justify-between">
          <div>
            <CardTitle class="flex items-center gap-2">
              <Tag class="h-5 w-5" />
              标记管理
            </CardTitle>
            <CardDescription>管理所有标记的信息</CardDescription>
          </div>

          <!-- 创建标记对话框 -->
          <Dialog v-model:open="createDialogOpen">
            <DialogTrigger as-child>
              <Button>
                <Plus class="mr-2 h-4 w-4" />
                新建标记
              </Button>
            </DialogTrigger>
            <DialogContent class="sm:max-w-[500px]">
              <DialogHeader>
                <DialogTitle>新建标记</DialogTitle>
                <DialogDescription>填写标记信息并提交</DialogDescription>
              </DialogHeader>

              <form @submit.prevent="handleCreate">
                <div class="space-y-4 py-4">
                  <!-- 设备ID -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDeviceId">设备ID</Label>
                    <DeviceIDSelect v-model="createForm.device_id" />
                    <span v-if="createV$.device_id.$error" class="text-destructive text-sm">
                      {{ createV$.device_id.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- 标记名称 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkName">标记名称</Label>
                    <Input
                      id="createMarkName"
                      v-model="createForm.mark_name"
                      placeholder="请输入标记名称"
                      :class="{ 'border-destructive': createV$.mark_name.$error }"
                    />
                    <span v-if="createV$.mark_name.$error" class="text-destructive text-sm">
                      {{ createV$.mark_name.$errors[0].$message }}
                    </span>
                  </div>

                  <!-- 标记类型 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createMarkType">标记类型</Label>
                    <TypeSelect v-model="createForm.mark_type_id" />
                  </div>

                  <!-- 危险半径 -->
                  <div class="flex flex-col gap-2">
                    <Label for="createDangerZone">危险半径（米）</Label>
                    <Input
                      id="createDangerZone"
                      :value="createForm.danger_zone_m ?? ''"
                      type="number"
                      step="0.1"
                      placeholder="留空表示使用类型默认值"
                      @input="
                        ($event.target as HTMLInputElement).value === ''
                          ? (createForm.danger_zone_m = null)
                          : (createForm.danger_zone_m = parseFloat(
                              ($event.target as HTMLInputElement).value,
                            ))
                      "
                    />
                  </div>

                  <!-- 标签 -->
                  <div class="flex flex-col gap-2">
                    <Label>标签</Label>
                    <TagsInput v-model="createForm.tags">
                      <template v-if="createForm.tags && createForm.tags.length">
                        <TagsInputItem v-for="tag in createForm.tags" :key="tag" :value="tag">
                          <TagsInputItemText />
                          <TagsInputItemDelete />
                        </TagsInputItem>
                      </template>
                      <TagsInputInput placeholder="输入标签后按 Enter 添加" />
                    </TagsInput>
                  </div>

                  <!-- 保存历史轨迹 -->
                  <div class="flex items-center gap-2">
                    <Switch id="createPersistMqtt" v-model:checked="createForm.persist_mqtt" />
                    <Label for="createPersistMqtt">保存历史轨迹</Label>
                  </div>
                </div>

                <DialogFooter>
                  <Button type="button" variant="outline" @click="createDialogOpen = false">
                    取消
                  </Button>
                  <Button type="submit" :disabled="isCreating">
                    {{ isCreating ? "创建中..." : "创建" }}
                  </Button>
                </DialogFooter>
              </form>
            </DialogContent>
          </Dialog>
        </div>
      </CardHeader>
    </Card>

    <!-- 标记列表 -->
    <MarkTablePager :key="tableKey" :fetcher="listMarks" :limit="10" />
  </div>
</template>
