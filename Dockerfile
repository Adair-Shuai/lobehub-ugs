# ============================================================
# LobeHub UGS — 自定义品牌镜像
#
# 基于官方 canary 镜像，叠加白标资源、预设助手与技能。
# CI 每 6 小时自动检查上游更新并重建。
#
# 使用方式：
#   1. 替换 branding/ 下的 LOGO / Favicon 文件
#   2. 编辑 agents/index.json 增删助手
#   3. skills/ 下按子目录放 SKILL.md
#   4. git push → CI 构建 → docker compose up -d
# ============================================================

FROM lobehub/lobehub:canary

USER root

# ---- 品牌资源 ----
# 需要覆盖 public/ 根和 _spa/ 两个位置（主页面 + SPA 路由均会引用）
COPY branding/logo.svg     /app/public/logo.svg
COPY branding/logo.svg     /app/public/_spa/logo.svg
COPY branding/favicon.ico  /app/public/favicon.ico
COPY branding/favicon.ico  /app/public/_spa/favicon.ico
COPY branding/og-image.png /app/public/og-image.png

# ---- 预设助手（Agent 市场内建数据）----
COPY agents/ /app/public/avatars/agents/

# ---- 预设技能 ----
COPY skills/ /app/public/skills/

# ---- 权限修正（新文件归应用用户所有）----
RUN chown -R nextjs:nodejs /app/public/logo.svg \
    /app/public/_spa/logo.svg \
    /app/public/favicon.ico \
    /app/public/_spa/favicon.ico \
    /app/public/og-image.png \
    /app/public/avatars/agents \
    /app/public/skills

USER nextjs
