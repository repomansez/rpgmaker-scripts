#!/bin/sh


## Generic script to convert any RPGMaker MV/MZ game to Linux

export nwjs_version=0.78.0
export gamedir="${1}"
export newgamedir="nwjs-sdk-v${nwjs_version}-linux-x64"

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
	fi
}
get_nwjs(){
	if [ -f nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz ]; then
		echo "nwjs already downloaded, skipping..."
	else
		echo "Downloading nwjs"
		if ! curl -L -f --progress-bar -O https://dl.nwjs.io/v${nwjs_version}/nwjs-sdk-v${nwjs_version}-linux-x64.tar.gz; then
			echo "error downloading nwjs"; exit 1
		else	
			echo "nwjs downloaded"
		fi
		sleep 2
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

	cd ${newgamedir}
	echo "Downloading scripts"
	sleep 1
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/LINUX.README
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/install_cheatmenu.sh
	curl -L -f --progress-bar -O https://raw.githubusercontent.com/repomansez/rpgmaker-scripts/refs/heads/master/game.sh
	chmod u+x game.sh install_cheatmenu.sh
}
package_game(){
	echo "do you wish to package the game? y/n"
	read -r package
	case ${package} in
		y)
			echo "what is the name and version of the game? (e.g. OverconfidentExorcistLinuxv1.01"
			read -r gamename
			export gamever="${gamename}"
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

nwjs_warning
pre_checks
get_nwjs
unpack_nwjs
convert
package_game
