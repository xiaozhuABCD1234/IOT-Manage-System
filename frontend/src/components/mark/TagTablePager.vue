<template>
  <div class="flex w-full flex-col">
    <!-- 表格 -->
    <Card class="flex-1">
      <CardContent class="p-0">
        <ScrollArea class="h-[calc(100vh-18rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>ID</TableHead>
                <TableHead>分组名称</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow v-for="tag in rows" :key="tag.id" class="hover:bg-muted/50">
                <TableCell class="font-medium">{{ tag.id }}</TableCell>
                <TableCell>
                  <RouterLink :to="`/tag/${tag.id}`" class="hover:underline">
                    <Badge variant="outline" class="text-sm">
                      <Hash class="mr-1 h-3 w-3" />
                      {{ tag.tag_name }}
                    </Badge>
                  </RouterLink>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 查看按钮 -->
                    <RouterLink :to="`/tag/${tag.id}`">
                      <Button variant="outline" size="icon" title="查看详情">
                        <Eye class="h-4 w-4" />
                      </Button>
                    </RouterLink>

                    <!-- 删除按钮 -->
                    <TagDelete :id="tag.id" @deleted="refresh" />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </ScrollArea>
      </CardContent>
    </Card>

    <!-- 分页 -->
    <Pagination
      v-slot="{ page }"
      :items-per-page="limit"
      :total="total"
      :default-page="1"
      @update:page="go"
      class="mt-4"
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
import type { MarkTagResponse } from "@/types/mark";
import type { ListParams } from "@/api/types";
import { Eye, Hash } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import TagDelete from "./TagDeleteDialog.vue";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { ScrollArea } from "@/components/ui/scroll-area";
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
    /* 数据源函数，接收 { page, limit }，返回 Promise<ApiResponse<MarkTagResponse[]>> */
    fetcher: (p: ListParams) => Promise<any>;
    /* 每页条数 */
    limit?: number;
  }>(),
  { limit: 10 },
);

/* 内部状态 */
const rows = ref<MarkTagResponse[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);

/* 拉数据 */
async function go(page = 1) {
  currPage.value = page;

  // 更新 URL 查询参数
  router.replace({
    query: { ...route.query, page: String(page) },
  });

  const { data } = await props.fetcher({ page, limit: props.limit });
  rows.value = data.data;
  total.value = data.pagination.totalItems;
}

/* 刷新当前页 */
function refresh() {
  go(currPage.value);
}

/* 自动加载 */
watchEffect(() => go(currPage.value));
</script>
