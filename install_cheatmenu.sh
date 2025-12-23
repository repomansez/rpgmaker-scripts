#!/bin/sh

# Installs emerladCoder's cheat menu in Overconfident Exorcist

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

detect_rpgmver() {
	       if [ -d "www" ]; then
		echo "RPGMaker MV detected"
		export RPGM_VERSION="MV"
	elif [ -d "js" ]; then
		echo "RPGMaker MZ detected"
		export RPGM_VERSION="MZ"
	fi
}
download_plugins_mv(){
	curl -L \
  -o www/js/plugins/Cheat_Menu.css \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.css && \
curl -L \
  -o www/js/plugins/Cheat_Menu.js \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.js
}

download_plugins_mz(){
	
	curl -L \
  -o js/plugins/Cheat_Menu.css \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.css && \
curl -L \
  -o js/plugins/Cheat_Menu.js \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.js
}

patch_pluginsjs(){ # This code comes directly from emerladCoder's github
	echo "Searching for and patching RPGM Plugins.js"
	#PATTERN='$!N; $s/\n]/,{"name":"Cheat_Menu","status":true,"description":"","parameters":{}}\n]/'
	PATTERN='s/}}$/}},{"name":"Cheat_Menu","status":true,"description":"","parameters":{}}/'
	if [ ${RPGM_VERSION} = "MV" ]; then
		cp -v www/js/plugins.js www/js/plugins.js~ 2>/dev/null &&
		sed -i "$PATTERN" www/js/plugins.js
		download_plugins_mv
	elif [ ${RPGM_VERSION} = "MZ"  ]; then
		cp -v js/plugins.js js/plugins.js~ 2>/dev/null &&
		sed -i "$PATTERN" js/plugins.js
		download_plugins_mz
	else
    		echo "No RPGM installation found."
fi
}



detect_rpgmver
patch_pluginsjs
