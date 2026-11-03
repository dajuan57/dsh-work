# 工作台 C:\Users\mazix\work

> DSH 自动加载（AGENTS.md 链）。这里有 `.git`，是项目根。
> 机器级规则（网络限制、权限判定、协作方式）在全局 `~/.dsh/AGENTS.md`，本文只写工作台自己的事。

## 目录

| 目录 | 用途 |
|---|---|
| `projects/` | 具体项目，每个项目自带 `.git` 和自己的 `AGENTS.md` |
| `data/` | 数据与素材；原始文件只读，派生结果另存 |
| `tmp/` | 临时产物，可随时清空 |
| `tools/` | 便携工具（PortableGit 等），不入版本库 |
| `notes/` | 笔记与档案；**不自动加载**，需要时再读 |

## 运行时（绝对路径，别猜）

- **Python 3.12**
  `C:\Users\mazix\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe`
- **Node 24 / pnpm**
  `…\dependencies\node\bin\node.exe`
  `…\dependencies\pnpm\bin\pnpm.mjs`（不在 PATH，用 `node <pnpm.mjs>` 调）
- **Git 2.56（便携版，免管理员，已入用户 PATH）**
  `C:\Users\mazix\work\tools\PortableGit\cmd\git.exe`
- **Office / PDF：用自带引擎**
  ```text
  "<node>" "<DSH>\resources\app.asar.unpacked\dsh\node_modules\@deepseek-ai\libreoffice-kit\lib\cli.js" convert --input <in> --output <out.pdf>
  ```
  支持 doc/docx/odt/xls/xlsx/ods/ppt/pptx/odp → pdf，另有 xlsx 重算与渲染 PNG。
  细节加载 `office`、`office-export-pdf`、`office-render`、`office-recalculate` 技能。

## Git 约定

- 一个里程碑一次提交；信息格式 `类型: 说明`（feat / docs / chore / fix）。
- 不提交 `.env`、`tools/`、`tmp/`。
- 新建项目：`projects/<名字>/` 自带 `.git` + 自己的 `AGENTS.md`。

## 干活规矩

1. 改之前先读；删或移动之前核对绝对路径。
2. 密钥只从 `.env` 或环境变量读；不写进源码、不贴聊天、不进 git。
3. 有验收标准的自己验：跑脚本、重开文件、核对数字。
4. 结果落成文件，不要只留在对话里。
5. 工作区权限异常时，先看 `notes/2026-11-03-环境搭建记录.md`，别自己乱改 ACL。
