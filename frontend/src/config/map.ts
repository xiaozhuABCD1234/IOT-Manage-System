export const MAP_CONFIG = {
  key: import.meta.env.VITE_AMAP_KEY,
  securityJsCode: import.meta.env.VITE_AMAP_SECURITY_CODE,
  version: "2.0",
  plugins: ["AMap.Scale"] as const,
  defaultCenter: [121.891751, 30.902079] as [number, number],
  defaultZoom: 17,
};
