<script setup lang="ts">
import DangerTypeSelect from "@/components/TypeSelect.vue";

import DeviceIDSelect from "@/components/DeviceIDSelect.vue";
import { ref } from "vue";

const selectedUnnamedId = ref<string>("");
const typeId = ref<number>();
</script>

<template>
  <DangerTypeSelect v-model="typeId" />
  <p>当前选中的类型 id：{{ typeId }}</p>
  <DeviceIDSelect v-model="selectedUnnamedId" />
  <p>当前选中的标签 id：{{ selectedUnnamedId }}</p>
</template>
