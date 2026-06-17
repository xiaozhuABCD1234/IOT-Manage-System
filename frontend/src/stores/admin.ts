// src/stores/admin.ts
import { defineStore } from "pinia";
import { ref } from "vue";
import { markApi, userApi } from "@/api";
import { useMarksStore } from "./marks";

export const useAdminStore = defineStore("admin", () => {
  const deviceCount = ref(0);
  const userCount = ref(0);
  const loading = ref(false);
  const error = ref<string | null>(null);

  const onlineCount = ref(0);

  async function fetchDashboardStats() {
    loading.value = true;
    error.value = null;
    try {
      const [marksRes, usersRes] = await Promise.all([
        markApi.listMarks({ limit: 1 }),
        userApi.listUsers({ page: 1, limit: 1 }),
      ]);

      // Total devices from pagination
      deviceCount.value = marksRes.data.pagination?.totalItems ?? 0;

      // Total users from pagination
      userCount.value = usersRes.data.pagination?.totalItems ?? 0;

      // Online devices from marks store
      const marksStore = useMarksStore();
      onlineCount.value = marksStore.onlineCount;
    } catch (err) {
      error.value = (err as Error).message;
    } finally {
      loading.value = false;
    }
  }

  return {
    deviceCount,
    userCount,
    onlineCount,
    loading,
    error,
    fetchDashboardStats,
  };
});