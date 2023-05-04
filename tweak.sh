#!/bin/bash

# Set default values
font_size='11'
big_font_size='12'
small_font_size='10'
sf_mode=false
alias_file=./fonts.conf

# Parse arguments
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -s|--size)
    font_size="$2"
    big_font_size=$((font_size + 1))
    small_font_size=$((font_size - 1))
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

echo "Base font size: $font_size pt" 
echo "Small font size: $small_font_size pt" 
echo "Bigger font size: $big_font_size pt" 

if [ "$sf_mode" = true ] ; then
  echo "Using Sans Francisco Pro"
  if [ "$sf_mode" = true ] ; then
  echo "Using Sans Francisco Pro"
  # Check if SF Pro Display and SF Pro Text are already installed
  if fc-list | grep -q "SF Pro Display" && fc-list | grep -q "SF Pro Text"; then
    echo "SF Pro Display and SF Pro Text are already installed"
  else
    # Install SF Pro Display and SF Pro Text
    sudo mkdir -p /usr/share/fonts/truetype/SF\ Pro/
    sudo cp -R fonts/SF_Pro/* /usr/share/fonts/truetype/SF\ Pro/
    alias_file=./fonts_SF.conf
  fi
else
  echo "Using Inter font"
fi
else
  echo "Using Inter font"
fi

echo "Installing presequite app..."
sudo apt install fonts-inter gnome-tweaks font-manager -y

# Check if Jetbrains Mono is already installed
if fc-list | grep -q "JetBrains Mono"; then
  echo "JetBrains Mono is already installed"
else
  # Install Jetbrains Mono
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
fi


echo "Update GNOME configuration..."

# update fonts
if [ "$sf_mode" = true ] ; then
  gsettings set org.gnome.desktop.interface document-font-name "SF Pro Text $font_size"
  gsettings set org.gnome.desktop.interface font-name "SF Pro Display $font_size"
  gsettings set org.gnome.desktop.interface monospace-font-name "Jetbrains Mono $big_font_size"
  gsettings set org.gnome.desktop.wm.preferences titlebar-font "SF Pro Display Bold $big_font_size"
else
  gsettings set org.gnome.desktop.interface document-font-name "Inter $font_size"
  gsettings set org.gnome.desktop.interface font-name "Inter Display $font_size"
  gsettings set org.gnome.desktop.interface monospace-font-name "Jetbrains Mono $big_font_size"
  gsettings set org.gnome.desktop.wm.preferences titlebar-font "Inter Bold $big_font_size"
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

echo "clearing font cache..."
fc-cache -fv > /dev/null 2>&1

echo "Successfully, please logout and login again!"