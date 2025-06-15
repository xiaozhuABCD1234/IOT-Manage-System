<template>
  <el-card>
    <template #header>
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <span>安全距离管理</span>
        <el-button type="primary" @click="addRow">新增安全距离</el-button>
      </div>
    </template>
    <el-table :data="safetyDistanceList" style="width: 100%" size="small">
      <el-table-column prop="type" label="安全类型" width="180">
        <template #default="scope">
          <el-input v-model="scope.row.type" size="small" :disabled="scope.row.editing !== true" />
        </template>
      </el-table-column>
      <el-table-column prop="value" label="安全距离值 (cm)">
        <template #default="scope">
          <el-input-number v-model="scope.row.value" :min="0" :max="100000" size="small" :disabled="scope.row.editing !== true" />
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

interface SafetyDistanceItem {
  type: string;
  value: number;
  editing?: boolean;
}

const STORAGE_KEY = 'safety_distance_list';
const safetyDistanceList = ref<SafetyDistanceItem[]>([]);

// 加载本地安全距离数据
const loadSafetyDistances = () => {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) {
    try {
      safetyDistanceList.value = JSON.parse(raw);
    } catch {}
  }
};

const saveSafetyDistances = () => {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(safetyDistanceList.value));
};

const addRow = () => {
  safetyDistanceList.value.push({ type: '', value: 0, editing: true });
};

const editRow = (idx: number) => {
  safetyDistanceList.value[idx].editing = true;
};

const saveRow = (idx: number) => {
  safetyDistanceList.value[idx].editing = false;
  saveSafetyDistances();
};

const cancelEdit = (idx: number) => {
  loadSafetyDistances(); // 重新加载以取消未保存的更改
  safetyDistanceList.value[idx].editing = false;
};

const deleteRow = (idx: number) => {
  safetyDistanceList.value.splice(idx, 1);
  saveSafetyDistances();
};

watch(safetyDistanceList, saveSafetyDistances, { deep: true });

loadSafetyDistances();

// 暴露安全距离列表给外部组件使用
defineExpose({
  safetyDistanceList
});
</script>

<style scoped>
</style> 