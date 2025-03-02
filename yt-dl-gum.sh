#!/bin/bash

# yt-dlp TUI Wrapper with gum
# ---------------------------------
# This script provides a simple TUI interface for yt-dlp,
# allows selecting audio or video formats,
# and automatically installs missing dependencies.
#
# Requirements:
# - gum (for the TUI)
# - yt-dlp (for downloading)
# - ffmpeg (for transcoding, merging etc)
# - A supported package manager (pacman, apt, brew)
#
# Author: blackbunt
# License: MIT

# Function to check if a list of commands is available
check_commands() {
    declare -A package_map
    package_map[aria2c]=aria2

    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            pkg_name=${package_map[$cmd]:-$cmd}
            #echo "Error: '$cmd' is not installed."
            prompt_install "$pkg_name"
        fi
    done
}

# Function to prompt the user before installing a missing program
prompt_install() {
    local package="$1"
    if [ "$package" == "gum" ]; then
        read -p "'$package' is missing. Do you want to install it? (y/N): " choice
    else
        gum confirm "'$package' is missing. Do you want to install it?" --affirmative="Yes" --negative="No" --default=Yes
        choice=$?
    fi
    if [[ "$choice" =~ ^[Yy]$ || "$choice" == "0" ]]; then
        install_command "$package"
    else
        echo "Skipping installation of '$package'. The script may not function correctly."
    fi
}

# Function to automatically install a missing program
install_command() {
    case "$(uname -s)" in
        Linux)
            if command -v pacman &> /dev/null; then
                echo "Installing '$1' with pacman..."
                sudo pacman -S --noconfirm "$1"
            elif command -v apt &> /dev/null; then
                echo "Installing '$1' with apt..."
                sudo apt update && sudo apt install -y "$1"
            else
                echo "No supported package manager found. Please install '$1' manually."
                exit 1
            fi
            ;;
        *)
            echo "Unsupported operating system. Please install '$1' manually."
            exit 1
            ;;
    esac
}

# Function to prompt for video URL using gum
gum_url_input() {
    gum input --placeholder "https://www.youtube.com/watch?v=..."
}

# Function to check and clean the video URL
clean_url() {
    local url="$1"
    url=$(echo "$url" | sed 's/\\//g')
    url=$(echo "$url" | sed -E 's/[?&]feature=shared(&|$)//g' | sed 's/[?&]$//')
    echo "$url"
}

# Function to prompt for or pass the video URL
get_video_url() {
    local url="$1"
    
    if [[ -n "$url" ]]; then
        echo "$(clean_url "$url")"
        return 0
    fi
    
    url=$(gum input --placeholder "Enter the video URL or press Enter to cancel:")
    [[ -z "$url" ]] && return 1
    
    clean_url "$url"
}

# Function to retrieve the video title
get_video_title() {
    local url="$1"
    yt-dlp --get-title "$url"
}

# Function to download as MP3 (Audio only)
download_audio() {
    local url="$1"
    yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 $SPONSORBLOCK "$url"
}

# Function to download as MP4 (Best Video, High Quality)
download_best_video() {
    local url="$1"
    local filename=$(yt-dlp --get-filename -o "%(title)s" "$url")
    yt-dlp -f "bv*+ba" --merge-output-format mp4 --write-sub --write-auto-sub --sub-lang "en,de" --embed-subs $SPONSORBLOCK "$url"
    filename=$(echo "$filename" | sed 's/\[.*\]//')
    remove_subtitles "$filename"
}

# Function to download as MP4 (Max 1080p)
download_1080p_video() {
    local url="$1"
    local filename=$(yt-dlp --get-filename -o "%(title)s" "$url")
    yt-dlp -f "bv*[height<=1080]+ba" --merge-output-format mp4 --write-sub --write-auto-sub --sub-lang "en,de" --embed-subs $SPONSORBLOCK "$url"
    filename=$(echo "$filename" | sed 's/\[.*\]//')
    remove_subtitles "$filename"
}

# Function to download as MP4 (iPhone compatible, Best Quality)
download_best_video_iphone() {
    local url="$1"
    local filename=$(yt-dlp --get-filename -o "%(title)s" "$url")
    yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]" --merge-output-format mp4 --recode-video mp4 --write-sub --write-auto-sub --sub-lang "en,de" --embed-subs $SPONSORBLOCK "$url"
    filename=$(echo "$filename" | sed 's/\[.*\]//')
    remove_subtitles "$filename"
}

# Function to download as MP4 (iPhone compatible, Max 1080p)
download_1080p_video_iphone(){
    local url="$1"
    local filename=$(yt-dlp --get-filename -o "%(title)s" "$url")
    yt-dlp -f "(bv*[height<=1080][ext=mp4]+ba[ext=m4a])/b[ext=mp4]" --merge-output-format mp4 --write-sub --write-auto-sub --sub-lang "en,de" --embed-subs $SPONSORBLOCK "$url"
    filename=$(echo "$filename" | sed 's/\[.*\]//')
    remove_subtitles "$filename"
}

# Function to remove subtitle files after embedding
remove_subtitles() {
    local filename="$1"
    for ext in "en.vtt" "de.vtt" "srt" "vtt"; do
        for file in "${filename}"*".${ext}"; do
            if [[ -f "$file" ]]; then
                rm -f "$file"
            fi
        done
    done
}

# Function to display colored output with gum
gum_echo() {
    local color="$1"
    local message="$2"
    gum style --bold --foreground "$color" "$message"
}

# Check if gum, yt-dlp, aria2c, and ffmpeg are installed
check_commands gum yt-dlp ffmpeg

# Exit on CTRL + C
trap "gum_echo '1' 'User aborted.'; exit 1" SIGINT

# Main Program
URL=$(get_video_url "$1")
[[ $? -ne 0 ]] && exit 0

# Verify URL and display title
TITLE=$(gum spin --spinner dot --title "Verifying URL" -- sh -c "yt-dlp --get-title '$URL'") || { gum_echo "1" "Error fetching title"; exit 1; }

gum style --bold --foreground 212 "$TITLE"

# Video+Audio or Audio selection
if gum confirm "What do you want to download?" --affirmative="Video" --negative="Audio only" --default=Yes; then
    if gum confirm "Should the video be optimized for iOS or does it not matter?" --affirmative="iOS" --negative="Doesn't matter" --default=Yes; then
        PLATFORM="iOS"
    else
        PLATFORM="Doesn't matter"
    fi
    if gum confirm "Which quality do you prefer? 1080p or the best available?" --affirmative="1080p" --negative="Best available" --default=Yes; then
        QUALITY="1080p"
    else
        QUALITY="Best available"
    fi
    # SponsorBlock: Remove sponsoring/ads?
    if gum confirm "Do you want to remove sponsored segments (SponsorBlock)?" --affirmative="Yes" --negative="No" --default=Yes; then
        SPONSORBLOCK="--sponsorblock-remove all"
    else
        SPONSORBLOCK=""
    fi
    if [[ "$PLATFORM" == "iOS" ]]; then
        if [[ "$QUALITY" == "1080p" ]]; then
            download_1080p_video_iphone "$URL" || { gum_echo "1" "Download error"; exit 1; }
        else
            download_best_video_iphone "$URL" || { gum_echo "1" "Download error"; exit 1; }
        fi
    else
        if [[ "$QUALITY" == "1080p" ]]; then
            download_1080p_video "$URL" || { gum_echo "1" "Download error"; exit 1; }
        else
            download_best_video "$URL" || { gum_echo "1" "Download error"; exit 1; }
        fi
    fi
else
    download_audio "$URL" || { gum_echo "1" "Download error"; exit 1; }
fi

gum_echo "2" "Download completed successfully!"
exit 0
