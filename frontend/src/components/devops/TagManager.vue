<template>
  <el-card>
    <template #header>
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <span>设备标签管理</span>
        <el-button type="primary" @click="addRow">新增标签</el-button>
      </div>
    </template>
    <el-table :data="tagList" style="width: 100%" size="small">
      <el-table-column prop="id" label="设备ID" width="120">
        <template #default="scope">
          <el-input v-model="scope.row.id" size="small" :disabled="scope.row.editing !== true" />
        </template>
      </el-table-column>
      <el-table-column prop="type" label="类型" width="100">
        <template #default="scope">
          <el-select v-model="scope.row.type" placeholder="请选择" size="small" :disabled="scope.row.editing !== true">
            <el-option label="人" value="person" />
            <el-option label="物" value="object" />
          </el-select>
        </template>
      </el-table-column>
      <el-table-column prop="label" label="标签信息">
        <template #default="scope">
          <el-input v-model="scope.row.label" size="small" :disabled="scope.row.editing !== true" />
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

interface TagItem {
  id: string;
  type: 'person' | 'object';
  label: string;
  editing?: boolean;
}

// 定义暴露给外部的接口类型
interface ExposedTagManager {
  getDeviceTag: (id: string) => TagItem | undefined;
  tagList: Ref<TagItem[]>;
}

const STORAGE_KEY = 'device_tag_list';
const tagList = ref<TagItem[]>([]);

// 加载本地标签数据
const loadTags = () => {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) {
    try {
      tagList.value = JSON.parse(raw);
    } catch {}
  }
};

const saveTags = () => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(tagList.value));
};

const addRow = () => {
  tagList.value.push({ id: '', type: 'person', label: '', editing: true });
};

const editRow = (idx: number) => {
  tagList.value[idx].editing = true;
};

const saveRow = (idx: number) => {
  tagList.value[idx].editing = false;
  saveTags();
};

const cancelEdit = (idx: number) => {
  loadTags();
  tagList.value[idx].editing = false;
};

const deleteRow = (idx: number) => {
  tagList.value.splice(idx, 1);
  saveTags();
};

watch(tagList, saveTags, { deep: true });

loadTags();

// 供地图等组件调用：获取标签信息
function getDeviceTag(id: string): TagItem | undefined {
  return tagList.value.find(t => t.id === id);
}

// 使用defineExpose暴露方法和数据给外部组件使用
defineExpose<ExposedTagManager>({
  getDeviceTag,
  tagList
});
</script> 
<style scoped>
</style> 