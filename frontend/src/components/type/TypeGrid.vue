<template>
  <Card class="h-full w-full">
    <CardHeader>
      <div class="flex items-center justify-between gap-2">
        <div>
          <CardTitle class="flex items-center gap-2">
            <Layers class="h-5 w-5" />
            类型列表
          </CardTitle>
          <CardDescription>查看所有标记类型及其默认危险半径</CardDescription>
        </div>
        <Button
          size="icon"
          variant="outline"
          @click="openCreateDialog"
          title="新增类型"
          aria-label="新增类型"
        >
          <Plus class="h-4 w-4" />
        </Button>
      </div>
    </CardHeader>
    <CardContent
      class="grid gap-4"
      :style="{ gridTemplateColumns: `repeat(auto-fill, minmax(${cardMinW}px, 1fr))` }"
    >
      <RouterLink
        v-for="t in types"
        :key="t.id"
        :to="`/type/${t.id}`"
        class="block rounded-lg focus:ring-2 focus:ring-offset-2 focus:outline-none"
      >
        <Card
          class="flex cursor-pointer flex-row items-center justify-between p-3 transition-shadow hover:shadow-md"
        >
          <div>{{ t.type_name }}</div>
          <div class="text-muted-foreground">{{ t.default_danger_zone_m }}m</div>
        </Card>
      </RouterLink>
    </CardContent>
  </Card>

  <!-- 新增类型对话框 -->
  <Dialog v-model:open="createOpen">
    <DialogContent>
      <DialogHeader>
        <DialogTitle>新增标记类型</DialogTitle>
        <DialogDescription>填写类型名称和默认危险半径（可选）。</DialogDescription>
      </DialogHeader>
      <div class="space-y-4">
        <div class="space-y-2">
          <Label for="type-name">类型名称 *</Label>
          <Input id="type-name" v-model="formName" placeholder="例如：人员、叉车" />
        </div>
        <div class="space-y-2">
          <Label for="type-danger">默认危险半径（米，可选）</Label>
          <Input
            id="type-danger"
            v-model.number="formDanger"
            type="number"
            min="0"
            placeholder="留空表示不设置"
          />
        </div>
      </div>
      <DialogFooter>
        <Button variant="outline" :disabled="submitting" @click="createOpen = false">取消</Button>
        <Button :disabled="!formName.trim() || submitting" @click="submitCreate">
          <Loader2 v-if="submitting" class="mr-2 h-4 w-4 animate-spin" />
          {{ submitting ? "创建中..." : "创建" }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>

  <!-- 底部提示 -->
  <!-- <div class="text-muted-foreground py-4 text-center text-xs">
    <span v-if="loading">加载中…</span>
    <span v-else-if="finished">没有更多了</span>
  </div> -->
</template>

<script setup lang="ts">
import { ref, onMounted } from "vue";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
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
import { Layers, Plus } from "lucide-vue-next";
import { listMarkTypes, createMarkType } from "@/api/mark/type";
import type { MarkTypeResponse } from "@/types/mark";
import { toast } from "vue-sonner";

/* ---------- 状态 ---------- */
const types = ref<MarkTypeResponse[]>([]);
const cardMinW = 150;
const loading = ref(false);
const finished = ref(false);
const page = ref(1);
const SIZE = 20; // 每页条数

/* ---------- 新增对话框 ---------- */
const createOpen = ref(false);
const formName = ref("");
const formDanger = ref<number | undefined>(undefined);
const submitting = ref(false);

function openCreateDialog() {
  formName.value = "";
  formDanger.value = undefined;
  createOpen.value = true;
}

async function submitCreate() {
  if (!formName.value.trim() || submitting.value) return;
  submitting.value = true;
  try {
    await createMarkType({
      type_name: formName.value.trim(),
      default_danger_zone_m: formDanger.value ?? null,
    });
    toast.success("创建成功", { description: `类型 \"${formName.value.trim()}\" 已创建` });
    createOpen.value = false;
    // 刷新列表：重置分页并重新加载
    types.value = [];
    page.value = 1;
    finished.value = false;
    await loadNext();
  } catch (e: any) {
    toast.error("创建失败", { description: e?.message ?? "请稍后重试" });
  } finally {
    submitting.value = false;
  }
}

/* ---------- 拉数据 ---------- */
async function loadNext() {
  if (loading.value || finished.value) return;
  loading.value = true;
  try {
    const { data } = await listMarkTypes({ page: page.value, limit: SIZE });
    // PaginationObj 的 items 字段才是数组
    const list = data.data ?? [];
    types.value.push(...list);
    // 后端返回不足一页说明到底了
    if (list.length < SIZE) finished.value = true;
    else page.value += 1;
  } finally {
    loading.value = false;
  }
}

/* ---------- 滚动到底检测 ---------- */
function onScroll(e: Event) {
  const el = e.target as HTMLElement;
  const { scrollTop, scrollHeight, clientHeight } = el;
  // 距离底部 <= 60px 就触发
  if (scrollHeight - scrollTop - clientHeight <= 60) {
    loadNext();
  }
}

/* ---------- 首次 ---------- */
onMounted(() => loadNext());
</script>
