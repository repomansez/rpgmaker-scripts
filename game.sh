#!/bin/sh
# Shell script to launch NWJS

# Copyleft (C) 2025 repomansez
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.#

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
make_nwjsdir() {
	mkdir -p userdata
}

launch_game() {
    case "$XDG_SESSION_TYPE" in
        wayland)
            ./nw --user-data-dir="${PWD}"/userdata --ozone-platform=wayland .
            ;;
        x11)
            ./nw --user-data-dir="${PWD}"/userdata .
            ;;
        *)
            echo "Unknown session type ($XDG_SESSION_TYPE). Falling back to X11 mode."
            ./nw --user-data-dir="${PWD}"/userdata --ozone-platform=x11 .
            ;;
    esac
}

check_prerequisites
make_nwjsdir
launch_game
