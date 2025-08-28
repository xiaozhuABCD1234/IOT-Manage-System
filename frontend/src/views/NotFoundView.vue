<template>
  <div class="not-found">
    <h1>404-未找到页面</h1>
    <p>您要查找的页面不存在。</p>
    <router-link to="/">
      <el-link type="primary"><h1>回到首页</h1></el-link></router-link>
  </div>
</template>

<style scoped>
.not-found {
  text-align: center;
  padding: 2rem;
}
</style>
