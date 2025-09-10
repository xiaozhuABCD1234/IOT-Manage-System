<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { 
  Location as ElIconLocation, 
  Monitor as ElIconMonitor, 
  DataAnalysis as ElIconDataAnalysis, 
  SetUp as ElIconSetUp,
  Setting as ElIconSetting,
  Box as ElIconBox,
  FirstAidKit as ElIconFirstAidKit,
  OfficeBuilding as ElIconOfficeBuilding
} from '@element-plus/icons-vue';

const router = useRouter();

const navigateTo = (path: string) => {
  router.push(path);
};
</script>

<template>
  <div class="landing-page">
    <!-- 顶部导航 -->
    <header class="header">
      <div class="logo-container">
        <img src="@/assets/imgs/iot.png" alt="Logo" class="logo" />
        <h1 class="logo-text">物联全域定位系统</h1>
      </div>
      <div class="nav-links">
        <a @click="navigateTo('/about')" class="nav-link">为什么选择思南</a>
        <a @click="navigateTo('/about')" class="nav-link">产品功能</a>
        <a @click="navigateTo('/about')" class="nav-link">解决方案</a>
        <a @click="navigateTo('/about')" class="nav-link">开发支持</a>
        <a @click="navigateTo('/about')" class="nav-link">商用服务</a>
      </div>
      <div class="auth-buttons">
        <el-button @click="navigateTo('/login')" type="primary">登录管理平台</el-button>
      </div>
    </header>

    <!-- 主横幅 -->
    <section class="hero">
      <div class="hero-content">
        <h1 class="hero-title">思南定位系统</h1>
        <p class="hero-subtitle">提供泛在全域定位解决方案</p>
        <el-button @click="navigateTo('/login')" type="primary" size="large" class="cta-button">开始使用</el-button>
      </div>
    </section>

    <!-- 定位标记点装饰 -->
    <div class="location-markers">
      <div class="marker marker-1">
        <div class="marker-label">工厂A</div>
      </div>
      <div class="marker marker-2">
        <div class="marker-label">物流中心</div>
      </div>
      <div class="marker marker-3">
        <div class="marker-label">医疗园区</div>
      </div>
      <div class="marker marker-4">
        <div class="marker-label">智慧社区</div>
      </div>
      <div class="marker marker-5">
        <div class="marker-label">数据中心</div>
      </div>
      <div class="marker marker-6">
        <div class="marker-label">商业园区</div>
      </div>
    </div>

    <!-- 功能特点 -->
    <section class="features">
      <h2 class="section-title">系统特点</h2>
      <div class="features-grid">
        <div class="feature-card">
          <el-icon :size="40" color="#409EFF"><el-icon-location /></el-icon>
          <h3>高精度定位</h3>
          <p>室内精度可达10cm，室外精度可达1m，满足各类场景需求</p>
        </div>
        <div class="feature-card">
          <el-icon :size="40" color="#409EFF"><el-icon-monitor /></el-icon>
          <h3>实时监控</h3>
          <p>支持多设备实时监控，轨迹追踪，状态预警</p>
        </div>
        <div class="feature-card">
          <el-icon :size="40" color="#409EFF"><el-icon-data-analysis /></el-icon>
          <h3>数据分析</h3>
          <p>提供全面的数据分析工具，助力业务决策优化</p>
        </div>
        <div class="feature-card">
          <el-icon :size="40" color="#409EFF"><el-icon-set-up /></el-icon>
          <h3>易于部署</h3>
          <p>简化的安装流程，快速部署，低成本维护</p>
        </div>
      </div>
    </section>

    <!-- 应用场景 -->
    <section class="scenarios">
      <h2 class="section-title">应用场景</h2>
      <div class="scenarios-grid">
        <div class="scenario-card">
          <h3>工业制造</h3>
          <p>人员安全监控、设备追踪、生产流程优化</p>
          <div class="scenario-icon">
            <el-icon-setting style="font-size: 36px; color: #409EFF;" />
          </div>
        </div>
        <div class="scenario-card">
          <h3>物流仓储</h3>
          <p>货物追踪、仓储优化、自动化调度</p>
          <div class="scenario-icon">
            <el-icon-box style="font-size: 36px; color: #409EFF;" />
          </div>
        </div>
        <div class="scenario-card">
          <h3>智慧医疗</h3>
          <p>患者定位、医疗设备管理、紧急呼叫</p>
          <div class="scenario-icon">
            <el-icon-first-aid-kit style="font-size: 36px; color: #409EFF;" />
          </div>
        </div>
        <div class="scenario-card">
          <h3>智慧园区</h3>
          <p>访客管理、资产追踪、安全监控</p>
          <div class="scenario-icon">
            <el-icon-office-building style="font-size: 36px; color: #409EFF;" />
          </div>
        </div>
      </div>
    </section>

    <!-- 技术优势 -->
    <section class="tech-advantage">
      <h2 class="section-title">技术优势</h2>
      <div class="tech-cards">
        <div class="tech-card">
          <div class="tech-number">01</div>
          <h3>多源融合定位</h3>
          <p>集成GPS、蓝牙、UWB、WiFi等多种定位技术，实现室内外无缝覆盖</p>
        </div>
        <div class="tech-card">
          <div class="tech-number">02</div>
          <h3>AI智能算法</h3>
          <p>基于深度学习的轨迹优化和预测算法，提高定位精度和可靠性</p>
        </div>
        <div class="tech-card">
          <div class="tech-number">03</div>
          <h3>云边协同架构</h3>
          <p>边缘计算与云端分析结合，保障实时性与数据安全</p>
        </div>
        <div class="tech-card">
          <div class="tech-number">04</div>
          <h3>开放生态系统</h3>
          <p>标准化API接口，支持与第三方系统快速集成和二次开发</p>
        </div>
      </div>
    </section>

    <!-- 底部信息 -->
    <footer class="footer">
      <div class="footer-content">
        <div class="footer-logo">
          <img src="@/assets/imgs/iot.png" alt="Logo" class="logo-small" />
          <span>物联全域定位系统</span>
        </div>
        <div class="footer-links">
          <div class="footer-column">
            <h4>产品</h4>
            <a href="#">功能介绍</a>
            <a href="#">技术规格</a>
            <a href="#">解决方案</a>
          </div>
          <div class="footer-column">
            <h4>支持</h4>
            <a href="#">开发文档</a>
            <a href="#">API参考</a>
            <a href="#">常见问题</a>
          </div>
          <div class="footer-column">
            <h4>公司</h4>
            <a href="#">关于我们</a>
            <a href="#">联系方式</a>
            <a href="#">合作伙伴</a>
          </div>
        </div>
      </div>
      <div class="copyright">
        © {{ new Date().getFullYear() }} 物联全域定位系统 版权所有
      </div>
    </footer>
  </div>
</template>

<style scoped>
.landing-page {
  min-height: 100vh;
  background-color: #f8f9fa;
  color: #333;
  font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
}

/* 顶部导航 */
.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 5%;
  background-color: white;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
}

.logo-container {
  display: flex;
  align-items: center;
}

.logo {
  height: 40px;
  margin-right: 10px;
}

.logo-text {
  font-size: 1.5rem;
  font-weight: 600;
  color: #4285f4;
  margin: 0;
}

.nav-links {
  display: flex;
  gap: 2rem;
}

.nav-link {
  color: #555;
  text-decoration: none;
  font-size: 1rem;
  cursor: pointer;
  transition: color 0.3s;
}

.nav-link:hover {
  color: #4285f4;
}

/* 主横幅 */
.hero {
  height: 100vh;
  background: linear-gradient(rgba(0, 0, 0, 0.5), rgba(0, 0, 0, 0.5)), url('/images/city-background.jpg') center/cover no-repeat;
  display: flex;
  align-items: center;
  justify-content: center;
  text-align: center;
  color: white;
  position: relative;
}

.hero-content {
  max-width: 800px;
  padding: 0 2rem;
  z-index: 2;
}

.hero-title {
  font-size: 3.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
}

.hero-subtitle {
  font-size: 1.5rem;
  margin-bottom: 2rem;
}

.cta-button {
  padding: 12px 30px;
  font-size: 1.1rem;
}

/* 定位标记点装饰 */
.location-markers .marker {
  position: absolute;
  width: 30px;
  height: 30px;
  background-color: rgba(66, 133, 244, 0.8);
  border-radius: 50%;
  transform: translate(-50%, -50%);
}

.marker::after {
  content: '';
  position: absolute;
  width: 100%;
  height: 100%;
  background-color: rgba(66, 133, 244, 0.4);
  border-radius: 50%;
  animation: pulse 2s infinite;
}

.marker-label {
  position: absolute;
  top: -25px;
  left: 50%;
  transform: translateX(-50%);
  background-color: rgba(255, 255, 255, 0.8);
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  white-space: nowrap;
  color: #333;
  opacity: 0;
  transition: opacity 0.3s;
}

.marker:hover .marker-label {
  opacity: 1;
}

.marker-1 { top: 20%; left: 15%; }
.marker-2 { top: 30%; left: 85%; }
.marker-3 { top: 60%; left: 25%; }
.marker-4 { top: 70%; left: 75%; }
.marker-5 { top: 40%; left: 50%; }
.marker-6 { top: 80%; left: 40%; }

@keyframes pulse {
  0% { transform: scale(1); opacity: 1; }
  100% { transform: scale(3); opacity: 0; }
}

/* 功能特点 */
.features {
  padding: 5rem 5%;
  background-color: white;
}

.section-title {
  text-align: center;
  font-size: 2.5rem;
  margin-bottom: 3rem;
  color: #333;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
}

.feature-card {
  background-color: #f8f9fa;
  border-radius: 10px;
  padding: 2rem;
  text-align: center;
  transition: transform 0.3s, box-shadow 0.3s;
}

.feature-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
}

.feature-card h3 {
  margin: 1rem 0;
  font-size: 1.5rem;
}

/* 应用场景 */
.scenarios {
  padding: 5rem 5%;
  background-color: #f8f9fa;
}

.scenarios-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
}

.scenario-card {
  background-color: white;
  border-radius: 10px;
  padding: 2rem;
  text-align: center;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s, box-shadow 0.3s;
  position: relative;
  overflow: hidden;
  z-index: 1;
}

.scenario-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
}

.scenario-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(90deg, #4285f4, #34a853, #fbbc05, #ea4335);
  z-index: 2;
  transform: scaleX(0);
  transform-origin: 0 50%;
  transition: transform 0.4s;
}

.scenario-card:hover::before {
  transform: scaleX(1);
}

.scenario-icon {
  margin-top: 1.5rem;
}

.scenario-card h3 {
  margin-bottom: 1rem;
  font-size: 1.5rem;
}

/* 技术优势 */
.tech-advantage {
  padding: 5rem 5%;
  background-color: #f0f4f8;
}

.tech-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 2rem;
  margin-top: 2rem;
}

.tech-card {
  background-color: white;
  border-radius: 10px;
  padding: 2rem;
  box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
  position: relative;
  transition: transform 0.3s, box-shadow 0.3s;
}

.tech-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 15px 30px rgba(0, 0, 0, 0.1);
}

.tech-number {
  position: absolute;
  top: 1rem;
  right: 1rem;
  font-size: 2.5rem;
  font-weight: 700;
  color: rgba(66, 133, 244, 0.1);
}

.tech-card h3 {
  margin: 1rem 0;
  font-size: 1.5rem;
  color: #4285f4;
}

/* 底部信息 */
.footer {
  background-color: #333;
  color: white;
  padding: 3rem 5% 1rem;
}

.footer-content {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  margin-bottom: 2rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.logo-small {
  height: 30px;
  margin-right: 10px;
}

.footer-links {
  display: flex;
  flex-wrap: wrap;
  gap: 3rem;
}

.footer-column h4 {
  margin-bottom: 1rem;
  font-size: 1.2rem;
}

.footer-column a {
  display: block;
  color: #ccc;
  margin-bottom: 0.5rem;
  text-decoration: none;
  transition: color 0.3s;
}

.footer-column a:hover {
  color: white;
}

.copyright {
  text-align: center;
  padding-top: 1rem;
  border-top: 1px solid #555;
  font-size: 0.9rem;
  color: #aaa;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .nav-links {
    display: none;
  }
  
  .hero-title {
    font-size: 2.5rem;
  }
  
  .features-grid,
  .scenarios-grid {
    grid-template-columns: 1fr;
  }
  
  .footer-content {
    flex-direction: column;
  }
  
  .footer-links {
    flex-direction: column;
    gap: 1rem;
  }
}
</style>
