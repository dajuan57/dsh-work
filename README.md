# 工作台 · C:\Users\mazix\work

给 DSH 用的通用工作区，不是一个产品仓库。规则细节见 [`AGENTS.md`](AGENTS.md)；机器级规则见 `~/.dsh/AGENTS.md`。

## 目录

| 目录 | 用途 | 是否入版本库 |
|---|---|---|
| `projects/` | 一个产品一个子目录，各自带 `.git` 和 `AGENTS.md` | 子目录内的内容由各自仓库管理 |
| `data/` | 数据与素材；原始文件只读，派生结果另存 | 是 |
| `notes/` | 笔记与档案，索引见 [`notes/README.md`](notes/README.md) | 是 |
| `tmp/` | 临时产物，可随时清空 | 否 |
| `tools/` | 便携工具（注意：该目录沙箱内只读，新东西放根目录） | 否 |

## 快速开始

```powershell
# 环境自检（11 项：Python/venv+核心库/Node/pnpm/Git/Office 引擎/真实 docx→PDF/指令文件/仓库/磁盘）
powershell -NoProfile -ExecutionPolicy Bypass -File .\check-env.ps1

# 新建项目（自动复制模板 + git init + 首次提交）
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\new-project.ps1 -Name demo -Desc "一句话说明这个项目做什么"
```

## 运行时（绝对路径，别猜）

| 工具 | 路径 |
|---|---|
| Python 3.12 | `C:\Users\mazix\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\python\python.exe` |
| 共享 venv | `C:\Users\mazix\work\.venv\Scripts\python.exe`（继承系统核心库 numpy/pandas/openpyxl/docx/pptx/Pillow/lxml/xlsxwriter；pip 用 `-m pip`，无 pip.exe） |
| Node 24 | `C:\Users\mazix\.dsh\dsh-runtimes\dsh-primary-runtime\dependencies\node\bin\node.exe` |
| pnpm | 用 `node <…\pnpm\bin\pnpm.mjs>` 调（不在 PATH） |
| Git 2.56 | `C:\Users\mazix\work\tools\PortableGit\cmd\git.exe`（已入 PATH） |
| VS Code | `C:\Users\mazix\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd`（重启终端后可直接 `code`） |
| uv | winget 装在 `…\WinGet\Packages\astral-sh.uv_…\uv.exe`，重启终端后 `uv` 直接在 PATH |
| Office/PDF | DSH 自带 `libreoffice-kit`，见 `AGENTS.md` |

## 约定

- 提交信息 `类型: 说明`（`feat` / `docs` / `chore` / `fix`），一个里程碑一次提交。
- 不提交 `.env`、`tools/`、`tmp/`、`node_modules/`（`.gitignore` 已覆盖）。
- 改之前先读；删或移动之前核对绝对路径；密钥只从 `.env` / 环境变量读。
- 换行与编辑器行为由 `.gitattributes` + `.editorconfig` 统一，不要手工改。
