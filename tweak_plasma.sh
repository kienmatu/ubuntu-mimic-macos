#!/bin/bash

# Set default values
font_size='11'
big_font_size='12'
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
  # Check if SF Pro Display and SF Pro Text are already installed
  if fc-list | grep -q "SF Pro Display" && fc-list | grep -q "SF Pro Text"; then
    echo "SF Pro Display and SF Pro Text are already installed"
  else
    # Install SF Pro Display and SF Pro Text
    sudo cp -R fonts/SF_Pro/* /usr/share/fonts/truetype/SF\ Pro/
    alias_file=./fonts_SF.conf
  fi
else
  echo "Using Inter font"
fi

echo "Installing presequite app..."
sudo apt install fonts-inter gnome-tweaks font-manager

# Check if Jetbrains Mono is already installed
if fc-list | grep -q "JetBrains Mono"; then
  echo "JetBrains Mono is already installed"
else
  # Install Jetbrains Mono
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)"
fi

echo "Update Plasma configuration..."

# update fonts
if [ "$sf_mode" = true ] ; then
  kwriteconfig5 --group "KDE" --key "font" "SF Pro Display,$font_size,-1,5,50,0,0,0,0,0"
  kwriteconfig5 --group "KDE" --key "smallestReadableFont" "SF Pro Text,$font_size,-1,5,50,0,0,0,0,0"
  kwriteconfig5 --group "WM" --key "titlebarFont" "SF Pro Display Bold,$big_font_size,-1,5,50,0,0,0,0,0"
else
  kwriteconfig5 --group "KDE" --key "font" "Inter Display,$font_size,-1,5,50,0,0,0,0,0"
  kwriteconfig5 --group "KDE" --key "smallestReadableFont" "Inter,$font_size,-1,5,50,0,0,0,0,0"
  kwriteconfig5 --group "WM" --key "titlebarFont" "Inter Bold,$big_font_size,-1,5,50,0,0,0,0,0"
fi
## ALIAS FILE
config_dir=~/.config/fontconfig

if [ ! -d file ]; then
  mkdir -p file
fi

sudo cp "$alias_file" "$config_dir/fonts.conf"

## >> is append, > is overwrite

echo "clearing cache..."
fc-cache -fv

echo "Successfully, please logout and login again!"