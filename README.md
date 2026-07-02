# LobeHub UGS — 企业定制版

基于 [LobeHub](https://github.com/lobehub/lobehub) 的自定义品牌镜像，自动跟随 canary 更新。

## 特性

- 🎨 **白标品牌** — 替换 LOGO、图标、名称
- 🤖 **内置助手** — 预装 6 个团队 Agent（3 通用 + 3 储气库专业）
- 🛠 **内置技能** — 预置 3 个储气库专业技能
- 🔄 **自动更新** — 每 6 小时检查上游 canary，自动构建新镜像

## 内置助手

| 图标 | 名称 | 类别 | 说明 |
|------|------|------|------|
| 💼 | 通用办公助手 | office | 文档撰写、数据分析、邮件起草 |
| 🔧 | 工程计算助手 | engineering | NeqSim 相平衡、pyResToolbox 储层计算 |
| 🧑‍💻 | 代码审查助手 | development | PR 审查、代码建议、lint 修复 |
| 🗺️ | 储气库地质建模助手 | ugs | 3D 构造建模、盖层评价、圈闭分析 |
| 📊 | 储气库注采优化助手 | ugs | 注采方案、物质平衡、井网优化 |
| 🛡️ | 储气库完整性评估助手 | ugs | 井筒完整性、腐蚀评价、风险矩阵 |

## 内置技能

| 技能 | 说明 |
|------|------|
| `ugs-capacity-calc` | 储气库库容量与工作气量计算 |
| `ugs-well-integrity` | 储气库井筒完整性分析 |
| `ugs-ipo-design` | 储气库注采方案辅助设计 |

## 完整流程

### 一、在 GitHub 上创建仓库

1. 打开 https://github.com/new
2. Repository name: `lobehub-ugs`
3. 建议设为 **Private**
4. **不要**勾选 "Add a README file"
5. 点击 "Create repository"

### 二、推送本地代码

```bash
cd E:\Lobehub-UGS
git remote add origin git@github.com:你的用户名/lobehub-ugs.git
git branch -m master main
git push -u origin main
```

推送后，GitHub Actions 会自动触发第一次构建。构建成功后，镜像在：
```
ghcr.io/你的用户名/lobehub-ugs:canary
```

### 三、部署到现有环境

在 `E:\Lobehub\docker-compose.yml` 中改一行：

```yaml
# 之前
lobehub:
  image: lobehub/lobehub:latest

# 之后
lobehub:
  image: ghcr.io/你的用户名/lobehub-ugs:canary
```

同时更新 `.env` 中的 Agent 索引地址，改为使用内置数据：

```bash
# 如果之前用的是 RustFS 外链，改成内网地址：
AGENTS_INDEX_URL=https://35dh5877hv55.vicp.fun/avatars/agents
# 或本机直连：
# AGENTS_INDEX_URL=http://localhost:3210/avatars/agents
```

> 注意：镜像已内置 agents 文件，`docker-compose.yml` 中不再需要挂载 `./data/agents` volume。

然后重建容器：

```bash
cd E:\Lobehub
docker compose --project-name lobehub pull lobehub
docker compose --project-name lobehub up -d
```

### 四、（可选）添加自动更新

在 `E:\Lobehub\docker-compose.yml` 末尾加入 Watchtower：

```yaml
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

### 五、日常维护

| 你要做的事 | 操作 |
|-----------|------|
| 换 LOGO | 替换 `branding/` 下的文件 → `git push` |
| 加新助手 | 编辑 `agents/index.json` → `git push` |
| 加新技能 | 在 `skills/` 下新建子目录 + `SKILL.md` → `git push` |
| 跟进上游更新 | **不需要操作**，CI 每 6 小时自动检查并构建 |

## 仓库结构

```
lobehub-ugs/
├── .github/workflows/build-custom.yml   ← CI：每 6 小时构建
├── Dockerfile                            ← 基于官方 canary 叠加
├── branding/                             ← 🎨 Logo / Favicon
│   ├── logo.svg
│   ├── favicon.ico
│   └── og-image.png
├── agents/
│   └── index.json                        ← 🤖 6 个预设助手
├── skills/                               ← 🛠 3 个储气库技能
│   ├── ugs-capacity-calc/SKILL.md
│   ├── ugs-well-integrity/SKILL.md
│   └── ugs-ipo-design/SKILL.md
└── docker-compose.example.yml
```

## 构建原理

```
官方 canary 镜像  +  你的品牌资产  =  企业定制镜像
      ↓                    ↓                  ↓
lobehub/lobehub     branding/         ghcr.io/YOU/lobehub-ugs
    :canary          agents/                 :canary
                     skills/
```

整个构建在 GitHub Actions 的 Ubuntu 环境完成，本地无需 Docker。
每次 `git push` 触发或每 6 小时自动触发。
