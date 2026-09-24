# Qoder CN Arch 自动发布实现计划

> **面向 AI 代理的工作者：** 必需子技能：使用 superpowers:executing-plans 逐任务实现此计划。步骤使用复选框（`- [ ]`）语法来跟踪进度。

**目标：** 自动把 Qoder CN 官方 deb 构建成 Arch Linux `pkg.tar.zst` 并发布到 GitHub Release。

**架构：** shell 脚本负责下载、解析版本、生成临时 PKGBUILD 和执行 makepkg；GitHub Actions 在 Arch Linux Docker 容器中调用脚本，并使用 GitHub CLI 发布新版本 Release。

**技术栈：** Bash、makepkg、Arch Linux `base-devel`、GitHub Actions、GitHub CLI。

---

### 任务 1：版本解析

**文件：**
- 创建：`scripts/package-version.sh`
- 测试：`tests/test-package-version.sh`

- [x] 编写 epoch、发行标识和非法版本的测试。
- [x] 运行测试确认缺少实现时失败。
- [x] 实现输出 `epoch`、`pkgver`、`tag` 和原始版本。
- [x] 运行测试确认通过。

### 任务 2：Arch 包构建

**文件：**
- 创建：`PKGBUILD.in`
- 创建：`qoder-cn.install`
- 创建：`scripts/build-package.sh`

- [x] 从官方 URL 下载 deb 并读取控制档案版本。
- [x] 生成临时 PKGBUILD，调用非 root makepkg，并输出包、校验和及版本元数据。
- [x] 在包安装脚本中刷新桌面缓存并设置 Chromium sandbox 权限。

### 任务 3：自动发布

**文件：**
- 创建：`.github/workflows/release.yml`

- [x] 配置每周定时和手动触发。
- [x] 在 Arch Linux 容器中构建。
- [x] 以新版本 tag 创建 Release，并上传包和 SHA256 清单。

### 任务 4：使用说明和验证

**文件：**
- 创建：`README.md`
- 创建：`.gitignore`
- 创建：`docs/superpowers/specs/2026-09-25-qoder-cn-arch-design.md`

- [x] 记录下载、校验、安装、卸载和自动更新方式。
- [ ] 在本地使用真实 deb 完成一次完整构建验证。
- [ ] 推送后检查 GitHub Actions 首次运行结果。
