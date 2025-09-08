<!-- src/views/MarkList.vue -->
<template>
  <!-- 整个页面：flex 列，高度 100% -->
  <div class="h-full w-full">
    <!-- 表格区域：ScrollArea 负责纵向滚动 -->
    <ScrollArea class="mx-auto h-[calc(100vh-7rem)] w-full max-w-4xl flex-1 rounded-md border mb-4">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead>设备ID</TableHead>
            <TableHead>标签名称</TableHead>
            <TableHead>类型</TableHead>
            <TableHead>标签</TableHead>
            <TableHead>最后在线时间</TableHead>
          </TableRow>
        </TableHeader>

        <TableBody>
          <TableRow
            v-for="mark in marks"
            :key="mark.id"
            class="hover:bg-gray-200 transition-colors h-15 dark:hover:bg-gray-700 border"
          >
            <TableCell>{{ mark.device_id }}</TableCell>
            <TableCell>{{ mark.mark_name }}</TableCell>
            <TableCell>{{ mark.mark_type?.type_name || "-" }}</TableCell>
            <TableCell>
              <div class="flex flex-wrap gap-1">
                <template v-if="mark.tags?.length">
                  <Badge v-for="tag in mark.tags" :key="tag.id" variant="outline">
                    {{ tag.tag_name }}
                  </Badge>
                </template>
                <span v-else>-</span>
              </div>
            </TableCell>
            <TableCell>
              {{
                mark.last_online_at ? new Date(mark.last_online_at).toLocaleString() : "从未上线"
              }}
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </ScrollArea>

    <!-- 分页栏：保持自身高度，贴底 -->
    <Pagination
      class=""
      v-slot="{ page }"
      :items-per-page="limit"
      :total="pagination?.totalItems ?? 0"
      :default-page="1"
      @update:page="onPageChange"
    >
      <PaginationContent v-slot="{ items }">
        <PaginationPrevious>上一页</PaginationPrevious>

        <template v-for="(item, idx) in items" :key="idx">
          <PaginationItem
            v-if="item.type === 'page'"
            :value="item.value"
            :is-active="item.value === page"
          >
            {{ item.value }}
          </PaginationItem>
        </template>

        <PaginationEllipsis :index="4" />
        <PaginationNext>下一页</PaginationNext>
      </PaginationContent>
    </Pagination>
  </div>
</template>

<script setup lang="ts">
import { Badge } from "@/components/ui/badge";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationFirst,
  PaginationItem,
  PaginationLast,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";

import { computed, ref, watchEffect } from "vue";
import { useRoute, useRouter } from "vue-router";

import { listMarks } from "@/api/mark";
import type { MarkResponse } from "@/types/mark";
import type { ApiResponse, PaginationObj } from "@/types/response";

const route = useRoute();
const router = useRouter();

/* 路径参数 */
const page = computed(() => Number(route.params.pageNumber));

/* 查询参数 */
const limit = computed(() => {
  const v = route.query.limit;
  // 没传、传空串、传非数字都走默认值
  return v && !Array.isArray(v) && /^\d+$/.test(v) ? Number(v) : 10;
});

const marks = ref<MarkResponse[]>([]);
const pagination = ref<PaginationObj>();

async function loadPage(page = 1, limit = 10) {
  const { data } = await listMarks({ page, limit, preload: true });
  marks.value = data.data;
  pagination.value = data.pagination;
}

/* 页码变化回调 */
function onPageChange(next: number) {
  // 1. 同步地址栏（保留其他 query）
  router.push({
    name: route.name!, // 保持当前路由名
    params: { ...route.params, pageNumber: next },
    query: { ...route.query }, // limit 等参数保持
  });
  // 2. 拉数据（watchEffect 会感知到路由变化，也可以直接在这里调用）
  // loadPage(next, limit.value);
}
watchEffect(() => {
  loadPage(page.value, limit.value);
});
</script>
