# Resolve Tools

A set of media ingest tools integrated into the Dolphin context menu to speed up the workflow for video editors on the KDE Plasma desktop.

`Resolve Tools` is a collection of Bash scripts designed to automate repetitive tasks when starting a new video editing project. With a simple right-click in the Dolphin file manager, you can create a standardized folder structure, recode video files for editing, and extract audio tracks.

This project is especially intended for users of editing software like DaVinci Resolve, who benefit from consistent media organization and performance-optimized file formats.

## ✨ Key Features

*   **Project Creation:** Generates a complete and customizable folder structure (Audio, Footage, Images, etc.) for a new project with a single command.
*   **Media Recoding:** Converts video files (MP4, MOV, etc.) to an `.mkv` format with audio in PCM (`pcm_s16le`), ideal for high-performance editing without visual quality loss.
*   **Audio Extraction:** Quickly extracts the audio track from any video file and saves it as a high-quality `.flac` file.
*   **KDE Dolphin Integration:** All actions are available directly in the Dolphin context menu, making the workflow fast and intuitive.
*   **GUI with `kdialog`:** Displays native KDE dialogs for user input and visual progress bars during operations.
*   **Multi-language Support:** Folders and dialogs are generated in either English or Spanish, automatically detecting the system language.

## ⚙️ Requirements

This project is designed for the **KDE Plasma desktop environment** and depends on the following command-line tools. Make sure you have them installed on your system:

*   `ffmpeg` and `ffprobe`: for video file manipulation and analysis.
*   `kdialog`: for displaying native KDE dialogs and notifications.
*   `qdbus`: for controlling `kdialog` progress windows.

## 🚀 Installation

The installation is managed through a helper script.

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/your-user/resolve-tools.git
    cd resolve-tools
    ```

2.  **Run the installation script:**
    This command will copy the necessary files to the KDE services directory.
    ```sh
    ./tools/manage.sh install
    ```

3.  **Restart Dolphin:**
    If the context menu doesn't appear immediately, you can restart Dolphin to load the new services.

## 🖥️ Usage

Once installed, the `Resolve Tools` options will appear in the Dolphin context menu (usually under the "Actions" or a dedicated submenu).

### Create Project Structure

1.  Navigate to the directory where you want to create your new project.
2.  Right-click on an empty area within the directory.
3.  Select **Resolve Tools → New Project**.
4.  A dialog will appear asking for the project name. Enter it and click "OK".
5.  A new folder with the project name and the entire defined subdirectory structure (Audio, Footage, Exports, etc.) will be created.

### Recode Media for Editing

1.  Navigate to the video file you want to optimize.
2.  Right-click on the file.
3.  Select **Resolve Tools → Recode Media**.
4.  The script will create a subfolder named `optimized_media` (if it doesn't exist) and save a version of the video in `.mkv` format with the audio recoded to PCM. A progress bar will show you the status of the operation.

### Extract Audio

1.  Navigate to the video or audio file from which you want to extract the sound.
2.  Right-click on the file.
3.  Select **Resolve Tools → Extract Audio**.
4.  The script will save a new version of the audio in `.flac` format in the same directory. If the original audio was already FLAC, it will simply be copied.

## 🛠️ Management Scripts

The project includes a management script at `tools/manage.sh` to facilitate the installation, uninstallation, and packaging of the tools.

```sh
./tools/manage.sh [command]
```

**Available commands:**

*   `install`: Installs the service menus on the local system (`~/.local/share/kio/servicemenus`).
*   `uninstall`: Removes all installation files from the system.
*   `package`: Creates a `tar.xz` distribution package in the project's root directory, ready to be shared.
