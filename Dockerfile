# ============================================================
# LobeHub UGS — 白标自定义镜像
#
# 基于官方 canary 镜像，替换品牌资源、预设助手与技能。
# CI 每 6 小时自动检查上游更新并重建。
#
# 构建参数:
#   BRAND_NAME  — 替换 "LobeHub" / "LobeChat" 的品牌名（默认 "UGS Hub"）
#
# 使用方式：
#   1. 替换 branding/ 下的 LOGO / Favicon 文件
#   2. 编辑 agents/index.json 增删助手
#   3. skills/ 下按子目录放 SKILL.md
#   4. git push → CI 构建 → docker compose up -d
# ============================================================

FROM lobehub/lobehub:canary

USER root

ARG BRAND_NAME="UGS Hub"

# ---- 1. 替换所有 favicon 文件（三个目录全覆盖）----
# LobeChat 有 ~14 种 favicon 变体分布在 public/、_spa/、_spa-auth/ 三个目录
# HTML 实际从 _spa-auth/ 加载，之前只覆盖 public/ 导致看不到变化
COPY branding/favicon.ico /tmp/favicon.ico
RUN for dir in /app/public /app/public/_spa /app/public/_spa-auth; do \
      if [ -d "$dir" ]; then \
        for f in favicon.ico favicon-32x32.ico favicon-dev.ico favicon-done.ico \
                 favicon-error.ico favicon-progress.ico favicon-32x-32-error.ico \
                 favicon-32x32-dev.ico favicon-32x32-done-dev.ico favicon-32x32-done.ico \
                 favicon-32x32-error-dev.ico favicon-32x32-progress-dev.ico \
                 favicon-32x32-progress.ico; do \
          if [ -f "$dir/$f" ]; then cp /tmp/favicon.ico "$dir/$f"; fi; \
        done; \
      fi; \
    done && rm /tmp/favicon.ico

# ---- 2. 替换 apple-touch-icon ----
COPY branding/og-image.png /tmp/og-image.png
RUN for dir in /app/public /app/public/_spa /app/public/_spa-auth; do \
      if [ -f "$dir/apple-touch-icon.png" ]; then cp /tmp/og-image.png "$dir/apple-touch-icon.png"; fi; \
    done && rm /tmp/og-image.png

# ---- 3. 替换 OG / 社交分享图 ----
COPY branding/og-image.png /app/public/og/og.webp

# ---- 4. 品牌名称替换 ----
# 将所有 JS/HTML/JSON 中的 "LobeHub" 和 "LobeChat" 替换为自定义品牌名
# 仅替换大写形式（品牌显示名），不影响小写的包名/URL
# 使用 sh 兼容语法（不用 find -print0 / xargs -0，避免 alpine 兼容问题）
RUN cd /app && \
    find public/_spa public/_spa-auth .next/server dist \
      -type f \( -name '*.js' -o -name '*.html' -o -name '*.json' \) \
      -print 2>/dev/null | while read f; do \
        sed -i "s/LobeHub/${BRAND_NAME}/g" "$f" 2>/dev/null; \
        sed -i "s/LobeChat/${BRAND_NAME}/g" "$f" 2>/dev/null; \
      done; \
    echo "Brand replacement done"

# ---- 5. 预设助手（Agent 市场内建数据）----
COPY agents/ /app/public/avatars/agents/

# ---- 6. 预设技能 ----
COPY skills/ /app/public/skills/

# ---- 7. 权限修正 ----
RUN chown -R nextjs:nodejs /app/public/

USER nextjs
