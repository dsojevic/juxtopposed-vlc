# Building this fork on macOS (Meson)

These steps build the redesigned Qt interface from source on macOS with
Homebrew dependencies and run it from the build tree. They were tested on
Apple Silicon (arm64) with macOS 27, the Xcode Command Line Tools (full
Xcode is not needed), Homebrew Qt 6.12.0, FFmpeg 8.0 and Meson 1.12.1.

This is a development build, not a distributable `VLC.app`: it uses the
Homebrew libraries on the machine that built it. On macOS the redesign is the
Qt interface (`-I qt`), not the Cocoa `macosx` interface.

## Prerequisites

Install the Command Line Tools (`xcode-select --install`) and
[Homebrew](https://brew.sh), then:

```sh
brew install meson ninja cmake pkg-config python bison flex \
    qt ffmpeg lua gnutls libarchive libpng freetype harfbuzz fribidi \
    libass dav1d opus libvorbis flac mpg123 x264 \
    libmatroska libebml taglib libdvbpsi
```

Most dependencies are `auto` options: if one is missing, that module is
disabled and the build still succeeds.

- **Bison 3.0 or later is required** for the WebVTT and JSON parsers.
  macOS ships Bison 2.3 in `/usr/bin`; Homebrew's `bison` and `flex` are
  keg-only, so put them first on `PATH` (shown below). With only the system
  Bison, those modules are skipped at configure time.
- The Qt interface needs Qt 6 `>= 6.2` with private headers. Homebrew's `qt`
  provides this; `-Dqt=enabled` makes a missing Qt a configure error.
- `medialibrary` is not packaged by Homebrew, so the media library is
  disabled. Playback and the player UI work. The library sidebar does not
  list local media.

## Configure and build

```sh
export PATH="$(brew --prefix bison)/bin:$(brew --prefix flex)/bin:$(brew --prefix qt)/bin:$(brew --prefix qt)/share/qt/libexec:$PATH"
export PKG_CONFIG_PATH="$(brew --prefix qt)/lib/pkgconfig:$(brew --prefix)/lib/pkgconfig"

git clone https://github.com/dsojevic/juxtopposed-vlc.git
cd juxtopposed-vlc
meson setup build -Dqt=enabled -Dtests=disabled -Dbuildtype=release
ninja -C build
```

`-Dtests=disabled` is currently needed because the test registration
requires the `medialibrary` plugin, which is not built here.

The default install prefix is the Homebrew prefix (`/opt/homebrew`). Do not
run `meson install` without passing `--prefix` to a private directory, or it
will install over Homebrew's tree.

## Running from the build tree

Use `build/bin/vlc-static`. It sets the plugin, library and `vlc-preparser`
paths to the build tree itself. `build/bin/vlc` looks in the install prefix
and exits with `VLC cannot start any interface` when nothing is installed
there.

```sh
build/bin/vlc-static -I qt /path/to/video.mp4
```

A quick headless check that decoding works:

```sh
build/bin/vlc-static -I dummy --no-video --aout=dummy --play-and-exit /path/to/video.mp4
```

Use `--no-video` for headless runs: `--vout=dummy` with the dummy interface
falls back to the `minimal_macosx` window module, which can crash in AppKit.

On Apple Silicon, H.264/HEVC playback uses VideoToolbox hardware decoding,
the `samplebufferdisplay` video output and the `auhal` audio output.
