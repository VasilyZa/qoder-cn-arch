# Qoder CN for Arch Linux

这个仓库把 Qoder CN 官方 Linux `.deb` 转换成 Arch Linux 可由 `pacman` 管理的离线安装包。

## 下载和安装

打开仓库的 [Releases](../../releases) 页面，下载最新的 `.pkg.tar.zst` 和对应的 `.sha256` 文件，然后校验并安装：

```bash
sha256sum -c qoder-cn-*.pkg.tar.zst.sha256
sudo pacman -U qoder-cn-*.pkg.tar.zst
```

安装包提供 `qoder-cn` 命令和桌面菜单项。卸载使用：

```bash
sudo pacman -Rns qoder-cn
```

## 自动更新

GitHub Actions 每周一检查 Qoder CN 官方下载地址，也支持在 Actions 页面手动运行。检测到尚未发布的版本后，工作流会在 Arch Linux 容器中构建包，并创建对应的 GitHub Release。

上游应用二进制文件属于 Qoder；本仓库只维护转换脚本和构建配置。
