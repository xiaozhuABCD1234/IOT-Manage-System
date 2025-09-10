<template>
  <el-card>
    <template #header>
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <span>基站管理</span>
        <el-button type="primary" @click="addRow">新增基站</el-button>
      </div>
    </template>
    <el-table :data="anchorList" style="width: 100%" size="small">
      <el-table-column prop="id" label="基站ID" width="120">
        <template #default="scope">
          <el-input v-model="scope.row.id" size="small" :disabled="scope.row.editing !== true" />
        </template>
      </el-table-column>
      <el-table-column prop="x" label="X坐标" width="120">
        <template #default="scope">
          <el-input-number 
            v-model="scope.row.x" 
            size="small" 
            :disabled="scope.row.editing !== true"
            :controls="false"
            :precision="0"
          />
        </template>
      </el-table-column>
      <el-table-column prop="y" label="Y坐标" width="120">
        <template #default="scope">
          <el-input-number 
            v-model="scope.row.y" 
            size="small" 
            :disabled="scope.row.editing !== true"
            :controls="false"
            :precision="0"
          />
        </template>
      </el-table-column>
      <el-table-column prop="coordinates" label="坐标字符串">
        <template #default="scope">
          <el-input 
            v-model="scope.row.coordinates" 
            size="small" 
            :disabled="scope.row.editing !== true"
            placeholder="[x, y]"
          />
        </template>
      </el-table-column>
      <el-table-column label="操作" width="180">
        <template #default="scope">
          <el-button v-if="!scope.row.editing" size="small" @click="editRow(scope.$index)">编辑</el-button>
          <el-button v-if="scope.row.editing" size="small" type="success" @click="saveRow(scope.$index)">保存</el-button>
          <el-button v-if="scope.row.editing" size="small" @click="cancelEdit(scope.$index)">取消</el-button>
          <el-button size="small" type="danger" @click="deleteRow(scope.$index)">删除</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup lang="ts">
import { ref, watch, type Ref } from 'vue';

interface AnchorItem {
  id: string | number;
  x: number;
  y: number;
  coordinates: string;
  editing?: boolean;
}

// 定义暴露给外部的接口类型
interface ExposedAnchorManager {
  getAnchor: (id: string | number) => AnchorItem | undefined;
  anchorList: Ref<AnchorItem[]>;
}

const STORAGE_KEY = 'uwb_anchor_list';
const anchorList = ref<AnchorItem[]>([]);

// 加载本地基站数据
const loadAnchors = () => {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) {
    try {
      anchorList.value = JSON.parse(raw);
    } catch (e) {
      console.error('Failed to parse anchors data:', e);
      // 如果没有数据或解析失败，添加默认基站
      resetToDefaultAnchors();
    }
  } else {
    // 如果没有数据，添加默认基站
    resetToDefaultAnchors();
  }
};

// 重置为默认基站
const resetToDefaultAnchors = () => {
  anchorList.value = [
    { id: 1, x: 0, y: 0, coordinates: "[0, 0]" },
    { id: 2, x: 600, y: 0, coordinates: "[600, 0]" },
    { id: 3, x: 0, y: 300, coordinates: "[0, 300]" },
  ];
  saveAnchors();
};

const saveAnchors = () => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(anchorList.value));
};

const addRow = () => {
  // 生成新的唯一ID
  const maxId = Math.max(0, ...anchorList.value.map(a => Number(a.id)));
  const newId = maxId + 1;
  
  // 默认放在地图中间位置
  anchorList.value.push({ 
    id: newId, 
    x: 500, 
    y: 500, 
    coordinates: "[500, 500]", 
    editing: true 
  });
};

const editRow = (idx: number) => {
  anchorList.value[idx].editing = true;
};

const saveRow = (idx: number) => {
  const anchor = anchorList.value[idx];
  
  // 更新坐标字符串，确保与x、y值匹配
  anchor.coordinates = `[${anchor.x}, ${anchor.y}]`;
  
  anchor.editing = false;
  saveAnchors();
};

const cancelEdit = (idx: number) => {
  loadAnchors();
  anchorList.value[idx].editing = false;
};

const deleteRow = (idx: number) => {
  anchorList.value.splice(idx, 1);
  saveAnchors();
};

watch(anchorList, saveAnchors, { deep: true });

loadAnchors();

// 供地图等组件调用：获取基站信息
function getAnchor(id: string | number): AnchorItem | undefined {
  return anchorList.value.find(a => String(a.id) === String(id));
}

// 使用defineExpose暴露方法和数据给外部组件使用
defineExpose<ExposedAnchorManager>({
  getAnchor,
  anchorList
});
</script>

<style scoped>
.el-input-number {
  width: 100%;
}
</style>
