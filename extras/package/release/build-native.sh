#!/usr/bin/env bash
# Native macOS/Linux builds. Install platform prerequisites first (doc/RELEASING.md).
set -euo pipefail
root=$(cd "$(dirname "$0")/../../.." && pwd)
cd "$root"
RELEASE_TAG=$(python3 "$root/extras/package/release/version.py")
export RELEASE_TAG
platform=$(uname -s)
if [[ "$platform" == Darwin ]]; then
    brew_prefix=$(brew --prefix)
    qt_prefix=${QT_ROOT_DIR:-$(brew --prefix qt)}
    gettext_prefix=$(brew --prefix gettext)
    export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$qt_prefix/bin:$qt_prefix/libexec:$qt_prefix/share/qt/libexec:$PATH"
    export PKG_CONFIG_PATH="$qt_prefix/lib/pkgconfig:$brew_prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
    for flag in CFLAGS CXXFLAGS OBJCFLAGS OBJCXXFLAGS; do
        export "$flag=${!flag:-} -I$gettext_prefix/include"
    done
    export LDFLAGS="${LDFLAGS:-} -L$gettext_prefix/lib"
    target=macos
    platform_options=(-Dxcb=disabled -Dwayland=disabled -Dtests=enabled)
else
    [[ "$platform" == Linux ]] || { echo 'Expected macOS or Linux' >&2; exit 1; }
    target=linux
    platform_options=(-Dxcb=enabled -Dwayland=enabled -Dtests=disabled)
fi
export RELEASE_DEPS_DIR=${RELEASE_DEPS_DIR:-"$root/build-release-$target-deps"}
bash extras/package/release/build-medialibrary.sh
export PKG_CONFIG_PATH="$RELEASE_DEPS_DIR/prefix/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
build="$root/build-release-$target"
if [[ ! -f "$build/build.ninja" ]]; then
    meson setup "$build" --prefix=/usr --libdir=lib --buildtype=release \
        -Dpkg_config_path="${PKG_CONFIG_PATH//:/,}" \
        -Dqt=enabled -Dupdate-check=enabled -Dmedialibrary=enabled -Dnls=enabled \
        -Dzvbi=disabled -Dlua=enabled -Dskins2=disabled "${platform_options[@]}"
else
    meson setup --reconfigure --clearcache "$build" --prefix=/usr --libdir=lib \
        -Dpkg_config_path="${PKG_CONFIG_PATH//:/,}" \
        -Dmedialibrary=enabled -Dupdate-check=enabled -Dskins2=disabled "${platform_options[@]}"
fi
meson compile -C "$build" -j "${JOBS:-4}"
if [[ "$target" == macos ]]; then
    # Exercise both proxy entry points and inherited request settings before
    # bundling. A missing platform wrapper must fail this build, not playback.
    meson compile -C "$build" -j "${JOBS:-4}" test_src_misc_configured_proxy
    meson test -C "$build" --no-rebuild --print-errorlogs test_src_misc_configured_proxy
fi
stage="$build/stage"
mkdir -p "$stage"
meson install -C "$build" --destdir="$stage" --no-rebuild
python3 extras/package/release/package.py "$target" "$stage/usr" --output "$root/build-release-output"
