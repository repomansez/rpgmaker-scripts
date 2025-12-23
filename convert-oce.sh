#!/bin/sh

## Convert Overconfident Exorcist from Windows to Linux

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
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

export nwjs_version=0.78.1
export gamedir="${1}"
export newgamedir="nwjs-sdk-v${nwjs_version}-linux-x64"
pre_checks(){
	if [ -z "${gamedir}" ] || [ ! -d "${gamedir}" ]; then
		echo  "Usage:
./convert-oce.sh ExtractedGameDirectory"
		exit 1
	fi
}

get_nwjs(){
	if [ -f nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz ]; then
		echo "nwjs already downloaded, skipping..."
	else
		wget https://dl.nwjs.io/v${nwjs_version}/nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz
	fi
}

unpack_nwjs(){
	if [ -d nwjs-sdk-v${nwjs_version}-linux-x64 ]; then
		echo "already extracted, delete it and extract again? (y/n)"
		read -r answer
			case "${answer}" in
				y)
					rm -rf nwjs-sdk-v${nwjs_version}-linux-x64
					tar xvf nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz
					;;
				n)
					echo "skipping..."
					;;
				*)
					echo "not understood"
					exit 1
					;;
			esac

	else
		tar xvf nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz
	fi
}

convert(){
	for p in audio css data effects fonts icon img js movies; do
    		cp -Rvp "$gamedir/$p" "$newgamedir" || exit 1
	done

	cp -vp \
    		"$gamedir/index.html" \
    		"$gamedir/package.json" \
    		"$newgamedir" || exit 1
	cd ${newgamedir}
	wget https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/LINUX.README
	wget https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/install_cheatmenu.sh
	wget https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/game.sh
	chmod u+x game.sh
}
package_game(){
	echo "do you wish to package the game? y/n"
	read -r package
	case ${package} in
		y)
			echo "what is the new version?"
			read -r version
			export gamever="OverconfidentExorcistLinuxv${version}"
			cd ../
			mv "${newgamedir}" "${gamever}"
			tar -vcJf "${gamever}.tar.xz" "${gamever}"
			;;
		n)
			exit 1
			;;
		*)
			exit 1
			;;
	esac
}

pre_checks
get_nwjs
unpack_nwjs
convert
package_game
