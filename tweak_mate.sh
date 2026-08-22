#!/usr/bin/env bash

set -e

font_size=11
sf_mode=false
revert_mode=false

usage() {
  cat <<'EOF'
Usage: ./tweak_mate.sh [options]

Options:
  -s, --size SIZE   Set the base font size in points (default: 11)
  -sf, --sf-mode    Use SF Pro instead of Inter
  -r, --revert      Restore the settings from before this script was run
  -h, --help        Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -s|--size)
      if [[ $# -lt 2 || ! "$2" =~ ^[0-9]+$ || "$2" -lt 6 || "$2" -gt 32 ]]; then
        echo "Error: --size must be a whole number between 6 and 32." >&2
        exit 2
      fi
      font_size="$2"
      shift 2
      ;;
    -sf|--sf-mode)
      sf_mode=true
      shift
      ;;
    -r|--revert)
      revert_mode=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

big_font_size=$((font_size + 1))
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/ubuntu-mimic-macos/mate"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fontconfig"
config_file="$config_dir/fonts.conf"
profile_file="$HOME/.profile"
stem_darkening='export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"'

if ! command -v gsettings >/dev/null 2>&1; then
  echo "Error: gsettings is required." >&2
  exit 1
fi

if ! gsettings list-schemas | grep -qx 'org.mate.interface' ||
   ! gsettings list-schemas | grep -qx 'org.mate.Marco.general'; then
  echo "Error: MATE settings were not found. Install the Ubuntu MATE desktop first." >&2
  exit 1
fi

has_caja_font_setting=false
if gsettings list-schemas | grep -qx 'org.mate.caja.desktop' &&
   gsettings list-keys org.mate.caja.desktop | grep -qx 'font'; then
  has_caja_font_setting=true
fi

restore_setting() {
  local schema="$1"
  local key="$2"
  local backup_file="$3"

  if [[ -f "$backup_file" ]]; then
    gsettings set "$schema" "$key" "$(<"$backup_file")"
  else
    gsettings reset "$schema" "$key"
  fi
}

if [[ "$revert_mode" == true ]]; then
  echo "Restoring the previous Ubuntu MATE font configuration..."
  restore_setting org.mate.interface font-name "$state_dir/interface-font"
  restore_setting org.mate.interface document-font-name "$state_dir/document-font"
  restore_setting org.mate.interface monospace-font-name "$state_dir/monospace-font"
  restore_setting org.mate.Marco.general titlebar-font "$state_dir/titlebar-font"
  if [[ "$has_caja_font_setting" == true ]]; then
    restore_setting org.mate.caja.desktop font "$state_dir/caja-font"
  fi

  if [[ -f "$state_dir/fontconfig.before" ]]; then
    mkdir -p "$config_dir"
    cp -f "$state_dir/fontconfig.before" "$config_file"
  elif [[ -f "$state_dir/fontconfig.absent" ]]; then
    rm -f "$config_file"
  elif [[ -f "$config_file" ]] &&
       { cmp -s "$config_file" "$script_dir/fonts.conf" ||
         cmp -s "$config_file" "$script_dir/fonts_SF.conf"; }; then
    # Compatibility for installations made before backup support existed.
    rm -f "$config_file"
  else
    echo "Fontconfig backup not found; the existing fonts.conf was left untouched."
  fi

  if [[ -f "$state_dir/stem-darkening-added" && -f "$profile_file" ]]; then
    temporary_profile="$(mktemp "${profile_file}.XXXXXX")"
    grep -vxF "$stem_darkening" "$profile_file" > "$temporary_profile" || true
    chmod --reference="$profile_file" "$temporary_profile"
    mv -f "$temporary_profile" "$profile_file"
  fi

  fc-cache -f >/dev/null
  echo "Done. Log out and log in again to finish reverting the changes."
  exit 0
fi

mkdir -p "$state_dir"
if [[ ! -f "$state_dir/settings.saved" ]]; then
  gsettings get org.mate.interface font-name > "$state_dir/interface-font"
  gsettings get org.mate.interface document-font-name > "$state_dir/document-font"
  gsettings get org.mate.interface monospace-font-name > "$state_dir/monospace-font"
  gsettings get org.mate.Marco.general titlebar-font > "$state_dir/titlebar-font"
  if [[ "$has_caja_font_setting" == true ]]; then
    gsettings get org.mate.caja.desktop font > "$state_dir/caja-font"
  fi
  touch "$state_dir/settings.saved"
fi

if [[ ! -f "$state_dir/fontconfig.before" && ! -f "$state_dir/fontconfig.absent" ]]; then
  if [[ -f "$config_file" ]]; then
    cp "$config_file" "$state_dir/fontconfig.before"
  else
    touch "$state_dir/fontconfig.absent"
  fi
fi

echo "Base font size: $font_size pt"
echo "Titlebar font size: $big_font_size pt"

echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y fonts-inter fontconfig curl

if [[ "$sf_mode" == true ]]; then
  echo "Using SF Pro"
  alias_file="$script_dir/fonts_SF.conf"
  interface_font="SF Pro Display $font_size"
  document_font="SF Pro Text $font_size"
  titlebar_font="SF Pro Display Bold $big_font_size"

  if ! fc-list | grep -q "SF Pro Display" || ! fc-list | grep -q "SF Pro Text"; then
    user_font_dir="${XDG_DATA_HOME:-$HOME/.local/share}/fonts/SF Pro"
    mkdir -p "$user_font_dir"
    cp -f "$script_dir"/fonts/SF_Pro/*.otf "$user_font_dir/"
    fc-cache -f "$user_font_dir"
  fi
else
  echo "Using Inter"
  alias_file="$script_dir/fonts.conf"
  interface_font="Inter $font_size"
  document_font="Inter $font_size"
  titlebar_font="Inter Bold $big_font_size"
fi

if ! fc-list | grep -qi "JetBrains Mono"; then
  echo "Installing JetBrains Mono..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
fi

echo "Updating MATE configuration..."
gsettings set org.mate.interface font-name "$interface_font"
gsettings set org.mate.interface document-font-name "$document_font"
gsettings set org.mate.interface monospace-font-name "JetBrains Mono $font_size"
gsettings set org.mate.Marco.general titlebar-font "$titlebar_font"

# Caja keeps a separate preference for labels shown on the desktop.
if [[ "$has_caja_font_setting" == true ]]; then
  gsettings set org.mate.caja.desktop font "$interface_font"
fi

mkdir -p "$config_dir"
cp -f "$alias_file" "$config_file"

touch "$profile_file"
if ! grep -qxF "$stem_darkening" "$profile_file"; then
  printf '\n%s\n' "$stem_darkening" >> "$profile_file"
  touch "$state_dir/stem-darkening-added"
fi

echo "Rebuilding the font cache..."
fc-cache -f >/dev/null

echo "Done. Log out and log in again to apply the changes everywhere."
