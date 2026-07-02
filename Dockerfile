# ============================================================
# LobeHub UGS - 自定义品牌镜像
# 基于官方 canary 镜像，叠加品牌资源、助手、技能
# 每次 canary 推送后 CI 自动重建，更新 docker-compose 即可
# ============================================================

FROM lobehub/lobehub:canary

# 切换到 root 以覆盖文件
USER root

# ---- 品牌资源（Logo / Favicon / OG Image）----
# 覆盖 SPA 构建产物中的对应文件
COPY branding/logo.svg        /app/public/_spa/logo.svg
COPY branding/favicon.ico     /app/public/_spa/favicon.ico
COPY branding/og-image.png    /app/public/_spa/og-image.png

# ---- 预设助手（内置 Agent 市场）----
# 用户无需联网即可看到团队预设的助手列表
COPY agents/ /app/public/avatars/agents/

# ---- 预设技能 ----
COPY skills/ /app/public/skills/

# ---- 确保文件权限正确 ----
RUN chown -R nextjs:nodejs /app/public/_spa/logo.svg \
    /app/public/_spa/favicon.ico \
    /app/public/_spa/og-image.png \
    /app/public/avatars/agents/ \
    /app/public/skills/

# 切回应用用户
USER nextjs
