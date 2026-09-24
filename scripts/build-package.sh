#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
work_root="${WORK_ROOT:-$repo_root/.build}"
output_dir="${OUTPUT_DIR:-$repo_root/dist}"
deb_url="${QODER_DEB_URL:-https://qoder-app.oss-cn-beijing.aliyuncs.com/qoder-app/releases/latest/Qoder-CN-linux-amd64.deb}"
deb_path="$work_root/qoder-cn.deb"
control_dir="$work_root/control"
package_dir="$work_root/package"

rm -rf "$work_root"
mkdir -p "$control_dir" "$package_dir" "$output_dir"
rm -f "$output_dir"/*.pkg.tar.* "$output_dir"/*.sha256 "$output_dir"/version.env

printf 'Downloading %s\n' "$deb_url"
curl -fL --retry 5 --retry-delay 2 -o "$deb_path" "$deb_url"

control_member="$(ar t "$deb_path" | awk '/^control\.tar\./ { print; exit }')"
case "$control_member" in
  *.xz) ar p "$deb_path" "$control_member" | tar -xJf - -C "$control_dir" ;;
  *.gz) ar p "$deb_path" "$control_member" | tar -xzf - -C "$control_dir" ;;
  *.zst) ar p "$deb_path" "$control_member" | tar --zstd -xf - -C "$control_dir" ;;
  *) printf 'unsupported control archive: %s\n' "$control_member" >&2; exit 1 ;;
esac

raw_version="$(awk -F': ' '$1 == "Version" { print $2; exit }' "$control_dir/control")"
if [[ -z "$raw_version" ]]; then
  printf 'Version field missing from Debian control file\n' >&2
  exit 1
fi

eval "$("$repo_root/scripts/package-version.sh" "$raw_version")"
sha256="$(sha256sum "$deb_path" | awk '{print $1}')"

sed \
  -e "s/@PKGVER@/$pkgver/g" \
  -e "s/@EPOCH@/$epoch/g" \
  -e "s/@SHA256@/$sha256/g" \
  "$repo_root/PKGBUILD.in" > "$package_dir/PKGBUILD"
cp "$repo_root/qoder-cn.install" "$package_dir/qoder-cn.install"
cp "$deb_path" "$package_dir/qoder-cn.deb"

build_as_builder() {
  (cd "$package_dir" && makepkg --clean --force --noconfirm)
}

if [[ "$EUID" -eq 0 ]]; then
  if ! id qoder-builder >/dev/null 2>&1; then
    useradd --create-home --uid 1000 qoder-builder
  fi
  chown -R qoder-builder:qoder-builder "$work_root" "$output_dir"
  runuser -u qoder-builder -- env HOME=/home/qoder-builder bash -c "cd '$package_dir' && makepkg --clean --force --noconfirm"
else
  build_as_builder
fi

package_path="$(find "$package_dir" -maxdepth 1 -type f -name '*.pkg.tar.*' -print -quit)"
if [[ -z "$package_path" ]]; then
  printf 'makepkg did not produce a package\n' >&2
  exit 1
fi

cp "$package_path" "$output_dir/"
package_file="$output_dir/$(basename "$package_path")"
sha256sum "$package_file" > "$package_file.sha256"
cat > "$output_dir/version.env" <<EOF
UPSTREAM_VERSION=$raw_version
PKGVER=$pkgver
EPOCH=$epoch
PKGREL=1
SOURCE_URL=$deb_url
SOURCE_SHA256=$sha256
PACKAGE_FILE=$(basename "$package_file")
EOF

printf 'Built %s\n' "$package_file"
