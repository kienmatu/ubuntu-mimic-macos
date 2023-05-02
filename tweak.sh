#!/bin/bash

# Set default values
font_size='11'
sf_mode=false
alias_file=./fonts.conf

# Parse arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--size)
    font_size="$2"
    shift 
    shift 
    ;;
    -sf|--sf-mode)
    sf_mode=true
    shift 
    ;;
    *)    
    shift 
    ;;
esac
done

echo "Base font size is $font_size" 

if [ "$sf_mode" = true ] ; then
  echo "Using Sans Francisco Pro"
  sudo cp -R fonts/SF_Pro/* /usr/share/fonts/truetype/SF\ Pro/
  alias_file=./fonts_SF.conf
else
  echo "Using Inter font"
fi

echo "Installing presequite app..."
sudo apt install fonts-inter gnome-tweaks font-manager

# # Jetbrains mono
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"


echo "Update GNOME configuration..."

# update fonts
if [ "$sf_mode" = true ] ; then
  gsettings set org.gnome.desktop.interface document-font-name 'SF Pro Text 11'
  gsettings set org.gnome.desktop.interface font-name 'SF Pro Display 11'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Jetbrains Mono 12'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'SF Pro Display Bold 12'
else
  gsettings set org.gnome.desktop.interface document-font-name 'Inter 11'
  gsettings set org.gnome.desktop.interface font-name 'Inter Display 11'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Jetbrains Mono 12'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Inter Bold 12'
fi
## ALIAS FILE
config_dir=~/.config/fontconfig

if [ ! -d file ]; then
  mkdir -p file
fi

sudo cp "$alias_file" "$config_dir/fonts.conf"

echo "Enabling STEM Darkening..."

## Enable STEM DARKENING
## Not useful for HiDPI monitor (4K)
if ! grep -qxF 'export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"' ~/.profile; then
  echo 'export FREETYPE_PROPERTIES="cff:no-stem-darkening=0"' >> ~/.profile
fi

## >> is append, > is overwrite

echo "clearing cache..."
fc-cache -fv

echo "Successfully, please logout and login again!"