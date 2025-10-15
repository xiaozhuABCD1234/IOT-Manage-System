<template>
  <div class="flex h-full w-full flex-col">
    <!-- 表格 -->
    <Card class="min-h-0 flex-1">
      <CardContent class="h-full p-0">
        <!-- 当数据量较少时，不使用滚动区域，让表格自然撑开 -->
        <div v-if="rows.length <= 10" class="flex h-full flex-col">
          <Table class="flex-1">
            <TableHeader>
              <TableRow>
                <TableHead>标记1</TableHead>
                <TableHead>标记2</TableHead>
                <TableHead>距离 (米)</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow
                v-for="pair in rows"
                :key="`${pair.mark1_id}-${pair.mark2_id}`"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark1_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark2_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="text-sm"> {{ pair.distance_m }}m </Badge>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <PairEditDialog :pair="pair" @updated="refresh" />

                    <!-- 删除按钮 -->
                    <PairDeleteDialog
                      :mark1-id="pair.mark1_id"
                      :mark2-id="pair.mark2_id"
                      @deleted="refresh"
                    />
                  </div>
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>

        <!-- 当数据量较多时，使用滚动区域 -->
        <ScrollArea v-else class="h-[calc(100vh-18rem)]">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>标记1</TableHead>
                <TableHead>标记2</TableHead>
                <TableHead>距离 (米)</TableHead>
                <TableHead class="text-right">操作</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              <TableRow
                v-for="pair in rows"
                :key="`${pair.mark1_id}-${pair.mark2_id}`"
                class="hover:bg-muted/50"
              >
                <TableCell class="font-medium">
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark1_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="outline" class="text-sm">
                    <Tag class="mr-1 h-3 w-3" />
                    {{ getMarkName(pair.mark2_id) }}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant="secondary" class="text-sm"> {{ pair.distance_m }}m </Badge>
                </TableCell>
                <TableCell class="text-right">
                  <div class="flex justify-end gap-2">
                    <!-- 编辑按钮 -->
                    <PairEditDialog :pair="pair" @updated="refresh" />

                    <!-- 删除按钮 -->
                    <PairDeleteDialog
                      :mark1-id="pair.mark1_id"
                      :mark2-id="pair.mark2_id"
                      @deleted="refresh"
                    />
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
      class="mt-4 mb-2"
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
import { ref, watchEffect, onMounted } from "vue";
import type { PairItem } from "@/types/distance";
import type { ListParams } from "@/api/types";
import { Tag } from "lucide-vue-next";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import PairDeleteDialog from "@/components/mark/PairDeleteDialog.vue";
import PairEditDialog from "@/components/mark/PairEditDialog.vue";
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
import { useRoute, useRouter } from "vue-router";
import { getPairsList } from "@/api/mark/pair";
import { getAllMarkIDToName } from "@/api/mark/index";

const route = useRoute();
const router = useRouter();

/* 外部传入 */
const props = withDefaults(
  defineProps<{
    /* 每页条数 */
    limit?: number;
  }>(),
  { limit: 10 },
);

/* 内部状态 */
const rows = ref<PairItem[]>([]);
const total = ref(0);
const currPage = ref(Number(route.query.page) || 1);
const markNames = ref<Record<string, string>>({});

/* 获取标记名称 */
const getMarkName = (markId: string) => {
  return markNames.value[markId] || markId;
};

/* 拉数据 */
async function go(page = 1) {
  currPage.value = page;

  // 更新 URL 查询参数
  router.replace({
    query: { ...route.query, page: String(page) },
  });

  const { data } = await getPairsList(page, props.limit);
  rows.value = data.data;
  total.value = data.pagination?.totalItems || 0;
}

/* 刷新当前页 */
function refresh() {
  go(currPage.value);
}

/* 加载标记名称映射 */
const loadMarkNames = async () => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.data) {
      markNames.value = response.data.data;
    }
  } catch (error) {
    console.error("加载标记名称失败:", error);
  }
};

/* 自动加载 */
watchEffect(() => go(currPage.value));

/* 组件挂载时加载标记名称 */
onMounted(() => {
  loadMarkNames();
});
</script>
