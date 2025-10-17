import { ref } from "vue";
import { getAllMarkIDToName } from "@/api/mark/index";

// 标记名称映射的全局状态
const markNames = ref<Record<string, string>>({});

// 是否已加载过标记名称
let isLoaded = false;

/**
 * 获取标记名称
 * @param markId 标记ID
 * @returns 标记名称，如果未找到则返回ID本身
 */
export const getMarkName = (markId: string): string => {
  return markNames.value[markId] || markId;
};

/**
 * 加载标记名称映射
 */
export const loadMarkNames = async (): Promise<void> => {
  try {
    const response = await getAllMarkIDToName();
    if (response.data.data) {
      markNames.value = response.data.data;
      isLoaded = true;
    }
  } catch (error) {
    console.error("加载标记名称失败:", error);
    throw error;
  }
};

/**
 * 确保标记名称已加载
 * 如果未加载过，则自动加载
 */
export const ensureMarkNamesLoaded = async (): Promise<void> => {
  if (!isLoaded) {
    await loadMarkNames();
  }
};

/**
 * 获取所有标记名称映射
 */
export const getAllMarkNames = (): Record<string, string> => {
  return markNames.value;
};

/**
 * 重置标记名称状态（用于测试或重新加载）
 */
export const resetMarkNames = (): void => {
  markNames.value = {};
  isLoaded = false;
};
