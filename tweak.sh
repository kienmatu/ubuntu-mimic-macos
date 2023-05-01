#!/bin/bash

echo "Base font size is 11"

sudo apt install fonts-inter gnome-tweaks font-manager

# # Jetbrains mono
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"

# update fonts
gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
gsettings set org.gnome.desktop.interface font-name 'Inter Display 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Jetbrains Mono 12'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 12'

## ALIAS
file=~/.config/fonts.conf

if [ ! -d ~/.config ]; then
  mkdir ~/.config
fi

cp ./fonts.conf $file


## Enable STEM DARKENING
## Not useful for HiDPI monitor (4K)
if ! grep -qxF 'export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"' ~/.profile; then
  echo 'export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"' >> ~/.profile
fi

source ~/.profile
## >> is append, > is overwrite