<template>
  <Card>
    <CardHeader>
      <CardTitle class="flex items-center gap-2">
        <Grid3x3 class="h-5 w-5" />
        批量配对安全距离
      </CardTitle>
      <CardDescription
        >一次性为两组标记 / 分组 / 类型之间的「全部组合」设定安全距离</CardDescription
      >
    </CardHeader>
    <CardContent>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- 第一组选择 -->
        <div class="bg-muted/50 space-y-3 rounded-lg p-4">
          <div class="mb-2 flex items-center gap-2">
            <Layers class="h-4 w-4" />
            <Label class="text-base font-semibold">分组集合一</Label>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="first-kind">选择范围</Label>
              <Select v-model="formData.first.kind" @update:model-value="handleFirstKindChange">
                <SelectTrigger id="first-kind">
                  <SelectValue placeholder="选择类型" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mark">标记名称 (选择单个标记)</SelectItem>
                  <SelectItem value="tag">分组 (选择所有分组一样的标记)</SelectItem>
                  <SelectItem value="type">类型 (选择所有类型一样的标记)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div v-if="formData.first.kind" class="space-y-2">
              <Label for="first-value">选择 {{ getKindLabel(formData.first.kind) }}</Label>
              <Select
                :model-value="getFirstValue()"
                @update:model-value="(value) => setFirstValue(value)"
              >
                <SelectTrigger id="first-value">
                  <SelectValue :placeholder="`选择${getKindLabel(formData.first.kind)}`" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="[id, name] in Object.entries(getOptionsForKind(formData.first.kind))"
                    :key="id"
                    :value="id"
                  >
                    {{ name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
        </div>

        <!-- 第二组选择 -->
        <div class="bg-muted/50 space-y-3 rounded-lg p-4">
          <div class="mb-2 flex items-center gap-2">
            <Layers class="h-4 w-4" />
            <Label class="text-base font-semibold">分组集合二</Label>
          </div>

          <div class="grid grid-cols-2 gap-4">
            <div class="space-y-2">
              <Label for="second-kind">选择范围</Label>
              <Select v-model="formData.second.kind" @update:model-value="handleSecondKindChange">
                <SelectTrigger id="second-kind">
                  <SelectValue placeholder="选择类型" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="mark">标记名称 (单个标记)</SelectItem>
                  <SelectItem value="tag">分组 (选择所有分组一样的标记)</SelectItem>
                  <SelectItem value="type">类型 (选择所有类型一样的标记)</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div v-if="formData.second.kind" class="space-y-2">
              <Label for="second-value">选择 {{ getKindLabel(formData.second.kind) }}</Label>
              <Select
                :model-value="getSecondValue()"
                @update:model-value="(value) => setSecondValue(value)"
              >
                <SelectTrigger id="second-value">
                  <SelectValue :placeholder="`选择${getKindLabel(formData.second.kind)}`" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem
                    v-for="[id, name] in Object.entries(getOptionsForKind(formData.second.kind))"
                    :key="id"
                    :value="id"
                  >
                    {{ name }}
                  </SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>
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
          <p class="text-muted-foreground text-sm">将为两组之间的所有标记对设置此距离</p>
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
import { Grid3x3, Layers, Save, RotateCcw } from "lucide-vue-next";
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
import { getAllTagIDToName } from "@/api/mark/tag";
import { getAllTypeIDToName } from "@/api/mark/type";
import { setCartesianDistance } from "@/api/mark/pair";
import type { SetCartesianDistanceRequest, Identifier, IdentifierKind } from "@/types/distance";

// 表单数据
const formData = ref<SetCartesianDistanceRequest>({
  first: {
    kind: "mark",
  },
  second: {
    kind: "mark",
  },
  distance: 0,
});

// 选项数据
const markOptions = ref<Record<string, string>>({});
const tagOptions = ref<Record<number, string>>({});
const typeOptions = ref<Record<number, string>>({});
const isSubmitting = ref(false);

// 表单验证
const isFormValid = computed(() => {
  const first = formData.value.first;
  const second = formData.value.second;

  const firstValid =
    (first.kind === "mark" && first.mark_id) ||
    (first.kind === "tag" && first.tag_id !== undefined) ||
    (first.kind === "type" && first.type_id !== undefined);

  const secondValid =
    (second.kind === "mark" && second.mark_id) ||
    (second.kind === "tag" && second.tag_id !== undefined) ||
    (second.kind === "type" && second.type_id !== undefined);

  return firstValid && secondValid && formData.value.distance >= 0;
});

// 辅助函数：获取类型分组
const getKindLabel = (kind: IdentifierKind) => {
  const labels: Record<IdentifierKind, string> = {
    mark: "标记名称",
    tag: "分组",
    type: "类型",
  };
  return labels[kind];
};

// 辅助函数：根据类型获取选项
const getOptionsForKind = (kind: IdentifierKind) => {
  switch (kind) {
    case "mark":
      return markOptions.value;
    case "tag":
      return tagOptions.value;
    case "type":
      return typeOptions.value;
    default:
      return {};
  }
};

// 获取和设置第一组的值
const getFirstValue = () => {
  const first = formData.value.first;
  if (first.kind === "mark") return first.mark_id || "";
  if (first.kind === "tag") return first.tag_id?.toString() || "";
  if (first.kind === "type") return first.type_id?.toString() || "";
  return "";
};

const setFirstValue = (value: any) => {
  if (!value) return;
  const valueStr = String(value);
  const kind = formData.value.first.kind;
  formData.value.first = { kind };

  if (kind === "mark") {
    formData.value.first.mark_id = valueStr;
  } else if (kind === "tag") {
    formData.value.first.tag_id = parseInt(valueStr);
  } else if (kind === "type") {
    formData.value.first.type_id = parseInt(valueStr);
  }
};

// 获取和设置第二组的值
const getSecondValue = () => {
  const second = formData.value.second;
  if (second.kind === "mark") return second.mark_id || "";
  if (second.kind === "tag") return second.tag_id?.toString() || "";
  if (second.kind === "type") return second.type_id?.toString() || "";
  return "";
};

const setSecondValue = (value: any) => {
  if (!value) return;
  const valueStr = String(value);
  const kind = formData.value.second.kind;
  formData.value.second = { kind };

  if (kind === "mark") {
    formData.value.second.mark_id = valueStr;
  } else if (kind === "tag") {
    formData.value.second.tag_id = parseInt(valueStr);
  } else if (kind === "type") {
    formData.value.second.type_id = parseInt(valueStr);
  }
};

// 处理第一组类型变化
const handleFirstKindChange = (kind: any) => {
  const kindStr = String(kind);
  if (!kindStr || (kindStr !== "mark" && kindStr !== "tag" && kindStr !== "type")) return;
  formData.value.first = { kind: kindStr };
};

// 处理第二组类型变化
const handleSecondKindChange = (kind: any) => {
  const kindStr = String(kind);
  if (!kindStr || (kindStr !== "mark" && kindStr !== "tag" && kindStr !== "type")) return;
  formData.value.second = { kind: kindStr };
};

// 加载所有选项数据
const loadAllOptions = async () => {
  try {
    const [markRes, tagRes, typeRes] = await Promise.all([
      getAllMarkIDToName(),
      getAllTagIDToName(),
      getAllTypeIDToName(),
    ]);

    console.log("加载选项数据:", {
      markRes: markRes.data,
      tagRes: tagRes.data,
      typeRes: typeRes.data,
    });

    // 响应拦截器已经处理了 code 检查，这里直接使用 data
    if (markRes.data.data) {
      markOptions.value = markRes.data.data;
    }
    if (tagRes.data.data) {
      tagOptions.value = tagRes.data.data;
    }
    if (typeRes.data.data) {
      typeOptions.value = typeRes.data.data;
    }
  } catch (error) {
    console.error("加载选项数据失败:", error);
    // 错误已在拦截器中处理，这里不再重复提示
  }
};

// 提交表单
const handleSubmit = async () => {
  if (!isFormValid.value) return;

  isSubmitting.value = true;
  try {
    const response = await setCartesianDistance(formData.value);
    // 响应拦截器已经处理了错误，能到这里说明成功
    toast.success("笛卡尔积距离设置成功");
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
    first: {
      kind: "mark",
    },
    second: {
      kind: "mark",
    },
    distance: 0,
  };
};

// 组件挂载时加载数据
onMounted(() => {
  loadAllOptions();
});
</script>
