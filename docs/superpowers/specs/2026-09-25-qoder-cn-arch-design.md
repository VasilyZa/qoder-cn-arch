# Qoder CN Arch 离线包设计

## 目标

建立公开 GitHub 仓库，定期检查 Qoder CN 官方 Linux deb 下载地址，并在版本更新时生成 Arch Linux `pkg.tar.zst` 离线安装包，作为 GitHub Release 附件发布。

## 方案

- 使用 Qoder CN 官网当前指向的 OSS 地址作为唯一上游来源。
- 使用 Arch Linux `base-devel` 容器执行 `makepkg`，避免构建机发行版影响包元数据。
- 构建脚本先读取 deb 的 Debian `Version` 字段，再生成临时 `PKGBUILD`，将 epoch、Arch 版本号和 deb SHA256 固化到包和 Release 说明中。
- GitHub Actions 每周定时运行，也支持手动触发；已存在相同版本 tag 时跳过发布。
- Release 同时上传 `.pkg.tar.zst` 和对应的 `.sha256`，仓库不提交上游二进制。

## 失败处理

- 下载失败、deb 缺少控制文件或版本格式无法映射时，工作流失败且不创建 Release。
- 上游数据归档格式不是当前支持的 `xz`、`gz` 或 `zst` 时，构建脚本失败并保留明确错误。
- 包构建成功但同版本 Release 已存在时，工作流正常结束且不重复上传。

## 验证

- 版本解析脚本使用 shell 测试覆盖 epoch、带发行标识的版本和非法版本。
- 构建脚本在本地 Arch 环境中使用真实 Qoder CN deb 运行，验证 pacman 包文件和 SHA256 清单。
