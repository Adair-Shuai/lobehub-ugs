# 团队 Skills 预置目录

此目录下的内容会在构建时被打包进镜像，团队成员启动后即可使用。

## 已内置的 Skills

| Skill | 说明 | 路径 |
|-------|------|------|
| ugs-capacity-calc | 储气库库容量与工作气量计算 | `ugs-capacity-calc/SKILL.md` |
| ugs-well-integrity | 储气库井筒完整性分析 | `ugs-well-integrity/SKILL.md` |
| ugs-ipo-design | 储气库注采方案辅助设计 | `ugs-ipo-design/SKILL.md` |

## 如何添加新 Skill

1. 在此目录下创建子文件夹，如 `my-skill/`
2. 在子文件夹中创建 `SKILL.md`，参考格式：

```markdown
---
name: my-skill
description: 简短描述这个技能的功能
version: 1.0.0
category: 分类
tags: [标签1, 标签2]
---

# My Skill

## 概述
简要说明技能用途。

## 适用场景
列出典型使用场景。

## 执行流程
分步骤描述工作流程。

## 输出模板
提供可复用的输出格式。
```

3. 提交后 push 到 GitHub，CI 自动重建镜像

## 注意

- Skill 文件名必须为 `SKILL.md`
- 每个 skill 一个子文件夹
- 参考已有的 `ugs-*` 三个 skill 的文件格式添加新 skill
