# ubuntu-mimic-macos
Mimic macOS font on GNOME Ubuntu

## Introduction
I want to bring the smooth font UX on macOS into Ubuntu GNOME.

So I chose the font `Inter`, it is the font used on Figma and ElementaryOS, and it is open-source.

You also have a choice to change the font into `SF Pro` to have exactly what runs on mac.

I also turned on the **STEM darkening**, that makes the font "bolder, thicker" like mac, but it doesn't work on HiDPI screen which has a big resolution like 4K.

I also use the font alias to trigger `-apple-system`, `Arial` font on almost websites to have a smooth UX thorough all the apps.

## Instructions

- Clone the repo:
    ```bash
    git clone https://github.com/kienmatu/ubuntu-mimic-macos.git
    ```
- Move to the folder:
    ```bash
    cd ubuntu-mimic-macos
    ```
- Make the file executable: 
    ```bash
    chmod +x ./tweak.sh
    ```
- run (without sudo)
    ```bash
    ./tweak.sh
    ``` 
- logout and login again.
- tadaaaa
### Options
- `-sf`,`--sf-mode`: Using Sans Francisco instead of Inter
- `-s`, `--size`: Change the font size, default font size is 11.

Example:
```bash
./tweak.sh -s 12 -sf
```

## Screenshots
### Before:
Github:
![Github](./screenshots/github_before.png)
Stackoverflow:
![Stackoverflow](./screenshots/stackoverflow_before.png)
Google:
![Google](./screenshots/google_before.png)

### After
Github:
![Github](./screenshots/github.png)
Stackoverflow:
![Stackoverflow](./screenshots/stackoverflow.png)
Google:
![Google](./screenshots/google.png)