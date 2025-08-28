FROM node:23-alpine

WORKDIR /app

# 先安装依赖（利用层缓存）
COPY package*.json ./
RUN npm config set registry https://registry.npmmirror.com \
    && npm install

# 再复制代码
COPY . ./

CMD ["npm", "start"]