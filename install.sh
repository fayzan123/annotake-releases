#!/bin/sh
# Installs Flipbook's latest early build, or updates the one you have.
#
#   curl -fsSL https://raw.githubusercontent.com/fayzan123/flipbook-releases/main/install.sh | sh
#
# It downloads Flipbook.zip from this repo's latest release, checks its signature,
# puts Flipbook in /Applications (or ~/Applications if you can't write there), and opens it.
# Your permissions carry over to each new build.
#
# For testing: FLIPBOOK_INSTALL_DIR=<folder> installs there instead, and quits and opens nothing.

set -eu

main() {
  zip_url="https://github.com/fayzan123/flipbook-releases/releases/latest/download/Flipbook.zip"

  [ "$(uname -s)" = Darwin ] || fail "this installer is for macOS."
  [ "$(sysctl -in hw.optional.arm64)" = 1 ] || fail "early builds run only on Apple silicon Macs (M1 or later)."
  version=$(sw_vers -productVersion)
  [ "${version%%.*}" -ge 15 ] || fail "Flipbook needs macOS 15 or later, and this Mac has macOS $version."

  testing=0
  if [ -n "${FLIPBOOK_INSTALL_DIR:-}" ]; then
    dest=$FLIPBOOK_INSTALL_DIR
    testing=1
  elif [ -w /Applications ]; then
    dest=/Applications
  else
    dest="$HOME/Applications"
  fi

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT

  echo "Downloading Flipbook…"
  curl -fsSL "$zip_url" -o "$tmp/Flipbook.zip" || fail "the download failed. Check your connection and run the command again."
  ditto -x -k "$tmp/Flipbook.zip" "$tmp/unzipped" || fail "couldn't unpack the download. Run the command again."
  app="$tmp/unzipped/Flipbook.app"
  codesign --verify --strict --deep "$app" 2>/dev/null || fail "the download looks damaged: its signature doesn't check out. Run the command again."

  if [ "$testing" = 0 ] && pgrep -xq Flipbook; then
    echo "Quitting the Flipbook that's running…"
    osascript -e 'tell application id "com.fayzanmalik.flipbook" to quit' >/dev/null 2>&1 || true
    i=0
    while pgrep -xq Flipbook && [ "$i" -lt 50 ]; do
      sleep 0.1
      i=$((i + 1))
    done
    pkill -x Flipbook 2>/dev/null || true
  fi

  mkdir -p "$dest"
  rm -rf "$dest/Flipbook.app"
  ditto "$app" "$dest/Flipbook.app"
  xattr -dr com.apple.quarantine "$dest/Flipbook.app" 2>/dev/null || true

  if [ "$testing" = 1 ]; then
    echo "Installed in $dest (test run: nothing quit or opened)."
    return
  fi

  # Keep one copy: an old one in the other Applications folder would confuse launch at login.
  for other in /Applications "$HOME/Applications"; do
    if [ "$other" != "$dest" ] && [ -d "$other/Flipbook.app" ]; then
      rm -rf "$other/Flipbook.app" 2>/dev/null || true
    fi
  done

  open "$dest/Flipbook.app"
  echo "Flipbook is installed in $dest and opening now."
  echo "Grant the three permissions it asks for, then double-tap Right ⌘ to record."
  echo "To update later, run the same command again."
}

fail() {
  echo "Flipbook: $*" >&2
  exit 1
}

main "$@"
