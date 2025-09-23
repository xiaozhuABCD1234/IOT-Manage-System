<template>
  <div class="flex w-full flex-col">
    <!-- 表格 -->
    <ScrollArea class="mx-auto mb-4 h-160 w-full max-w-4xl rounded-md border">
      <Table class="bg-card">
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
            v-for="mark in rows"
            :key="mark.id"
            class="h-15 border transition-colors hover:bg-gray-200 dark:hover:bg-gray-700"
          >
            <TableCell>{{ mark.device_id }}</TableCell>
            <TableCell>{{ mark.mark_name }}</TableCell>
            <TableCell>
              <RouterLink
                v-if="mark.mark_type"
                :to="`/type/${mark.mark_type.id}`"
                class="hover:underline"
              >
                {{ mark.mark_type.type_name }}
              </RouterLink>
              <span v-else>-</span>
            </TableCell>
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

    <!-- 分页 -->
    <Pagination
      v-slot="{ page }"
      :items-per-page="limit"
      :total="total"
      :default-page="1"
      @update:page="go"
    >
      <PaginationContent v-slot="{ items }">
        <PaginationPrevious>上一页</PaginationPrevious>

        <template v-for="(item, idx) in items" :key="idx">
          <PaginationItem
            v-if="item.type === 'page'"
            :value="item.value"
            :is-active="item.value === currPage"
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
import { ref, watchEffect } from "vue";
import type { MarkResponse } from "@/types/mark";
import type { ListParams } from "@/api/mark";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import {
  Pagination,
  PaginationContent,
  PaginationEllipsis,
  PaginationItem,
  PaginationNext,
  PaginationPrevious,
} from "@/components/ui/pagination";
import { RouterLink } from "vue-router";
import { useRoute, useRouter } from "vue-router";

const route = useRoute();
const router = useRouter();

/* 外部传入 */
const props = withDefaults(
  defineProps<{
    /* 数据源函数，接收 { page, limit }，返回 Promise<ApiResponse<MarkResponse[]>> */
    fetcher: (p: ListParams) => Promise<any>;
    /* 每页条数 */
    limit?: number;
  }>(),
  { limit: 10 },
);

/* 内部状态 */
const rows = ref<MarkResponse[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);

/* 拉数据 */
async function go(page = 1) {
  currPage.value = page;

  // 更新 URL 查询参数
  router.replace({
    query: { ...route.query, page: String(page) },
  });

  const { data } = await props.fetcher({ page, limit: props.limit, preload: true });
  rows.value = data.data;
  total.value = data.pagination.totalItems;
}

/* 自动加载 */
watchEffect(() => go(currPage.value));
</script>
