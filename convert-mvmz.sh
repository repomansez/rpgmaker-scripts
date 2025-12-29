#!/bin/sh

## Generic script to convert any RPGMaker MV/MZ game to Linux

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


export nwjs_version=0.78.0
export gamedir="${1}"
export nwjs_fulldir="nwjs-sdk-v${nwjs_version}-linux-x64"
export newgamedir="${nwjs_fulldir}"

nwjs_warning(){
	clear
	echo "WARNING:
	"
	echo "RPGMaker is for some reason VERY sensitive to different nwjs versions."
	echo "Sometimes even one subversion can be the difference between a game working or not even launching, so if you're having problems, try to experiment with different NW.js versions.
	"
	echo "RPGMaker MZ is newer so it's known to work better with newer NW.js versions, while RPGMaker MV usually breaks on anything over version 0.59.1."
	echo "The current selected nwjs version is v"${nwjs_version}""
	echo "If you wish to select a different version, please edit the nwjs_version variable
	"
	echo "Press enter if you wish to continue"
	read -r ass 
	clear
}

pre_checks(){
	if [ -z "${gamedir}" ] || [ ! -d "${gamedir}" ]; then
		echo  "Usage:
./convert-oce.sh ExtractedGameDirectory"
		exit 1
	fi

	if [ -d "${gamedir}/www" ]; then
		echo "RPGMaker MV detected"
		export RPGM_VERSION="MV"
	elif [ -d "${gamedir}/js" ]; then
		echo "RPGMaker MZ detected"
		export RPGM_VERSION="MZ"
	else 
		echo "Couldn't detect an RPG Maker game on the selected directory"
		exit 1
	fi
}
get_nwjs(){
	if [ -f "${nwjs_fulldir}.tar.gz" ]; then
		echo "nwjs already downloaded, skipping..."
	else
		echo "Downloading nwjs"
		if ! curl -L -f --progress-bar -O https://dl.nwjs.io/v${nwjs_version}/${nwjs_fulldir}.tar.gz; then
			echo "error downloading nwjs"; exit 1
		else	
			echo "nwjs downloaded"
		fi
		sleep 2
	fi
}

unpack_nwjs(){
	if [ -d "${nwjs_fulldir}" ]; then
		echo "nwjs directory located, delete it and extract again? (y/N)"
		read -r answer
			case "${answer}" in
				y)
					rm -rf "${nwjs_fulldir}"
					tar xvf "${nwjs_fulldir}.tar.gz"
					;;
				n)
					echo "skipping..."
					sleep 2
					;;
				*)
					echo "skipping..."
					sleep 2
					;;
			esac

	else
		tar xvf "${nwjs_fulldir}.tar.gz"
	fi
}

detect_copy_savedir(){
	if { [ -d "${gamedir}/save" ] && [ "${RPGM_VERSION}" = "MZ" ] } || 
	   { [ -d "${gamedir}/www/save" ] && [ "${RPGM_VERSION}" = "MV" ]; }; then
		echo "Save directory detected, do you wish to copy it? (y/n)"
			while :; do
				read -r ass
				case "${ass}" in
					y)
						break
						;;
					n)
						return
						;;
					*)
						echo "Incorrect option, try again"
						;;
				esac
			done
		case "${RPGM_VERSION}" in
			MZ)
				echo "Copying RPGMZ save directory"
				cp -rv "${gamedir}/save" "${newgamedir}"
				;;
			MV)
				echo "Copying RPGMV save directory"
				cp -rv "${gamedir}/www/save" "${newgamedir}"
				;;
			*)
				echo "If you can read this that means you broke the script somehow"
				;;
		esac
	else 
		echo "No save directory detected"
	fi
}
			
convert(){
	if [ "${RPGM_VERSION}" = "MZ" ]; then
					
		for p in audio css data effects fonts icon img js movies; do
			if [ -d "${gamedir}/${p}" ]; then
    				cp -Rvp "$gamedir/$p" "$newgamedir" || exit 1
			else
				echo "Skipping missing directory: ${p}"
			fi
		done

		cp -vp \
    			"$gamedir/index.html" \
    			"$gamedir/package.json" \
    			"$newgamedir" || exit 1
	elif [ "${RPGM_VERSION}" = "MV" ]; then
		cp -Rvp "${gamedir}/www" "${newgamedir}" 
		cp -vp \
			"${gamedir}/www/index.html" \
			"${gamedir}/package.json" \
			"${newgamedir}" || exit
	fi

	cd "${newgamedir}"
	echo "Downloading scripts"
	sleep 1
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/LINUX.README
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/install_cheatmenu.sh
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/game.sh
	chmod u+x game.sh install_cheatmenu.sh
	cd ../
}

rename_dir() {
	export guess="${gamedir}-linux"
	if [ -d "${guess}" ]; then
		echo "Directory ${guess} already present, do you wish to overwrite it, rename it or exit? (o/r/e)"
		while :; do
			echo "Answer: "
			read -r overwrite
			case "${overwrite}" in
				o) 
					rm -rf "${guess}"
					mv "${newgamedir}" "${guess}"
					break
					;;
				r)
					echo "Renaming ${guess} to ${guess}-$(date +%s)"
					sleep 2
					mv "${guess}" "${guess}-old"
					mv "${newgamedir}" "${guess}"
					break
					;;
				e)
					echo "Exiting"
					exit 1
					;;
				*)
					echo "Invalid option, try again"
					echo "Valid options are"
					echo "o for overwrite"
					echo "r for rename"
					echo "e for exit"
					;;
			esac
		done
	else 
		mv "$newgamedir" "$guess"
	fi
	
	echo "Final game extracted to ${guess}"
}

package_game(){
	echo "do you wish to package the game? y/n"
	read -r package
	case ${package} in
		y)
			echo "what is the name and version of the game? (e.g. OverconfidentExorcistLinuxv1.01)"
			echo "Leave blank for: ${guess}"
			read -r gamename
				if [ -z "${gamename}" ]; then
					gamever="${guess}"
					export gamever
				else
					gamever="${gamename}"
					export gamever
					mv "${guess}" "${gamever}"
				fi
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
nwjs_warning
get_nwjs
unpack_nwjs
convert
detect_copy_savedir
rename_dir
package_game
