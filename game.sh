#!/bin/sh
# Shell script to launch NWJS

check_prerequisites() {
    if [ "$(id -u)" = 0 ]; then
        echo "Do not run as root — run as the normal user you'll play the game with."
        exit 1
    fi

    if ! [ -f index.html ] || ! [ -d js ] && ! [ -d data ] && ! [ -d www ]; then
        echo "This does not look like a RPG Maker MZ/MV game directory."
        echo "Make sure this script is inside the game folder."
        exit 1
    fi

    if ! [ -f package.json ]; then
        echo "Missing package.json — cannot run NW.js game."
        exit 1
    fi

    if [ -n "$FLATPAK_ID" ]; then
        echo "Warning: Running inside Flatpak ($FLATPAK_ID) may break NW.js."
    fi

    if ! touch .write_test 2>/dev/null; then
        echo "Warning: Directory is read-only — saves may not work."
    else
        rm -f .write_test
    fi
}

launch_game() {
    case "$XDG_SESSION_TYPE" in
        wayland)
            ./nw --ozone-platform=wayland .
            ;;
        x11)
            ./nw .
            ;;
        *)
            echo "Unknown session type ($XDG_SESSION_TYPE). Falling back to X11 mode."
            ./nw --ozone-platform=x11 .
            ;;
    esac
}

check_prerequisites
launch_game
