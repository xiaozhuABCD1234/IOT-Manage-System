/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE: string;
  // 更多变量...
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
