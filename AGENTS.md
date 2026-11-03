# C:\work 工作区约定

> 本文件会被 DSH 自动加载（AGENTS.md 链）。C:\work 里有 `.git`，因此它是"项目根"。

## 这个目录是什么

工作台，不是单一仓库。项目、数据、临时产物、笔记都在这里。

| 目录 | 用途 |
|---|---|
| `projects/` | 具体项目，每个项目自带 `.git` |
| `data/` | 数据与素材（原始文件只读，派生结果另存） |
| `tmp/` | 临时产物，可随时清空 |
| `tools/` | 便携工具（PortableGit 等），不入版本库 |
| `notes/` | 笔记、文档产出 |

## 这台机器的环境（不要瞎猜，按这里来）

- **Python 3.12**
  `C:\Users\mazix\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe`
  PATH 里的 `python` 是应用商店占位程序，**别用**。
- **Node 24 / pnpm**
  `...\dependencies\node\bin\node.exe`
  `...\dependencies\pnpm\bin\pnpm.mjs`（不在 PATH，用绝对路径）
- **Git 2.56（便携版，无需管理员）**
  `C:\work\tools\PortableGit\cmd\git.exe`
- **Office / PDF 引擎：用自带的，不要装系统 LibreOffice**

  ```text
  "<node>" "C:\Users\mazix\AppData\Local\Programs\DeepSeek Harness\resources\app.asar.unpacked\dsh\node_modules\@deepseek-ai\libreoffice-kit\lib\cli.js" convert --input <in> --output <out.pdf>
  ```

  支持 doc/docx/odt/xls/xlsx/ods/ppt/pptx/odp → pdf、xlsx 重算、渲染成 png。
  具体用法加载 `office`、`office-export-pdf`、`office-render`、`office-recalculate` 技能。

## 网络

沙箱内 HTTPS 出站被拦截（curl 报 35），HTTP 可通。
需要下载或装包时：说清用途 → 申请 `danger-full-access` 执行一次；或让用户用浏览器下载。
国内镜像优先（npmmirror / 清华 TUNA / 阿里云）。

## 干活规矩

1. 改之前先读；删或移动之前核对绝对路径。
2. 密钥只从 `.env` 或环境变量读；不写进源码、不贴聊天、不进 git。
3. 有验收标准的自己验：跑脚本、重新打开生成的文件、核对数字。
4. 结果落成文件，不要只留在对话里。
5. 不在没打招呼的情况下装系统级软件、改注册表。

## 回复

中文。先结论后细节，结尾给"改了什么 + 怎么验证"。
