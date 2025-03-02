# yt-dlp TUI Wrapper with gum

A simple TUI wrapper for `yt-dlp` that allows selecting videos or audio files conveniently through an interactive interface. Missing dependencies are automatically detected and prompted for installation.

## Features
- **Simple TUI control** using `gum`
- **Support for both audio and video downloads**
- **Automatically embeds subtitles** (for English and German)
- **Automatic installation of missing dependencies**
- **SponsorBlock integration** (remove or mark sponsored segments)
- **Various output formats supported:**
  - Audio (MP3, best quality)
  - Video (Best available quality or max 1080p)
  - iPhone-compatible video formats

## Requirements
The script requires the following programs:

- [`gum`](https://github.com/charmbracelet/gum) (for the TUI)
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) (for downloading)
- [`ffmpeg`](https://ffmpeg.org/) (for transcoding and merging)

If any of these programs are missing, the script will offer to install them automatically.

## Installation
### Manual Installation
If the required programs are not installed, they can be manually installed as follows:

```sh
# Arch Linux / EndeavourOS
sudo pacman -S yt-dlp ffmpeg gum aria2

# Debian / Ubuntu
sudo apt update && sudo apt install -y yt-dlp ffmpeg gum aria2

# macOS (Homebrew)
brew install yt-dlp ffmpeg gum aria2
```

### Downloading the Script
Clone the repository or download directly:

```sh
git clone https://github.com/blackbunt/yt-dlp-tui.git
cd yt-dlp-tui
chmod +x yt-dlp-tui.sh
```

Alternatively, download the script directly:

```sh
curl -o yt-dlp-tui.sh https://raw.githubusercontent.com/blackbunt/yt-dlp-tui/main/yt-dlp-tui.sh
chmod +x yt-dlp-tui.sh
```

## Usage
The script can be executed directly from the terminal:

```sh
./yt-dlp-tui.sh
```

Alternatively, a video URL can be passed as a parameter:

```sh
./yt-dlp-tui.sh "https://www.youtube.com/watch?v=example"
```

### Selection Options
- **Download video or audio?**
- **If video:**
  - **Optimized for iPhone?** *(Choose an iOS-compatible format)*
  - **1080p or best available quality?**
- **If audio:** Automatically downloads in MP3 at the best quality.
- **SponsorBlock Integration:** Option to remove or mark sponsored segments.

## Troubleshooting
If the script does not work as expected:

1. Ensure all dependencies are installed:
   ```sh
   command -v yt-dlp ffmpeg gum aria2c
   ```
2. Update `yt-dlp` to the latest version:
   ```sh
   yt-dlp -U
   ```
3. Run the script with `bash -x` for debugging:
   ```sh
   bash -x yt-dlp-tui.sh
   ```
## Acknowledgments

A big thank you to the developers of the following tools that make this script possible:

- [`gum`](https://github.com/charmbracelet/gum) (for the TUI)
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) (for downloading)
- [`ffmpeg`](https://ffmpeg.org/) (for transcoding and merging)
- [’SponsorBlock’](https://sponsor.ajay.app/)(for skipping sponsored segments)

## License
This project is licensed under the **MIT License**.

## Author
- **blackbunt**

