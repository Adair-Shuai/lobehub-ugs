# 团队 Skills 预置目录

此目录下的内容会在构建时被打包进镜像，团队成员启动后即可使用。

## 如何添加 Skill

1. 在此目录下创建子文件夹，如 `my-skill/`
2. 在子文件夹中创建 `SKILL.md`，参考格式：

```markdown
---
name: my-skill
description: 简短描述这个技能的功能
---

# My Skill

## 触发条件
...

## 执行逻辑
...

## 示例
...
```

3. 提交后，CI 会自动将其打包进新镜像

## 注意

- Skill 文件名必须为 `SKILL.md`
- 每个 skill 一个子文件夹
- 前端加载 skills 的方式取决于 LobeHub 版本，请参考官方文档
