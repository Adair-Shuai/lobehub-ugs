# LobeHub UGS — 企业定制版

基于 [LobeHub](https://github.com/lobehub/lobehub) 的自定义品牌镜像，自动跟随 canary 更新。

## 特性

- 🎨 **白标品牌** — 替换 LOGO、图标、名称
- 🤖 **内置助手** — 预装团队专属 Agent，开箱即用
- 🛠 **内置技能** — 预置 Skills 无需手动导入
- 🔄 **自动更新** — 每 6 小时检查上游 canary，自动构建新镜像

## 快速开始

### 1. 替换品牌素材

把 `branding/` 目录下的占位文件替换为你自己的：
- `logo.svg` — 品牌 LOGO
- `favicon.ico` — 浏览器图标
- `og-image.png` — 分享预览图

### 2. 添加你的助手

编辑 `agents/index.json`，添加团队的专属助手配置。

### 3. 部署

```bash
# 拉取最新自定义镜像
docker pull ghcr.io/<你的用户名>/lobehub-ugs:canary

# 或使用 docker-compose（含自动更新）
docker compose -f docker-compose.yml up -d
```

## 本地 docker-compose 配置变更

在你的主 `E:\Lobehub\docker-compose.yml` 中，将 lobe 服务改为：

```yaml
services:
  lobe:
    image: ghcr.io/<你的用户名>/lobehub-ugs:canary  # ← 改为你的镜像
    container_name: lobehub
    ports:
      - '${LOBE_PORT}:3210'
    environment:
      # 使用内置助手索引（无需外网）
      - 'AGENTS_INDEX_URL=http://localhost:3210/avatars/agents/index.json'
      # ... 其余环境变量不变
    # 不再需要挂载 agents volume，已内置在镜像中
    # volumes:
    #   - ./data/agents:/app/public/avatars/agents:ro
    restart: always
    networks:
      - lobe-network

  # 新增：自动更新监控
  watchtower:
    image: containrrr/watchtower
    container_name: lobe-watchtower
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    command: --interval 3600 --cleanup lobehub
    restart: unless-stopped
    networks:
      - lobe-network
```

## 仓库结构

```
LobeHub-UGS/
├── .github/workflows/
│   └── build-custom.yml    ← CI 自动构建
├── Dockerfile               ← 基于官方 canary 叠加资源
├── branding/                ← 品牌素材（替换此目录文件）
├── agents/                  ← 预设助手配置
│   └── index.json
├── skills/                  ← 团队 Skills
└── README.md
```

## 构建原理

```
官方 canary 镜像
        ↓
   COPY branding/*    →  替换 Logo/Favicon
   COPY agents/*      →  内置助手市场
   COPY skills/*      →  预置技能
        ↓
   ghcr.io/<you>/lobehub-ugs:canary
        ↓
   Watchtower 自动拉取更新
```
