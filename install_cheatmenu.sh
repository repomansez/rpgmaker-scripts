#!/bin/sh

# Installs emerladCoder's cheat menu in Overconfident Exorcist

patch_pluginsjs(){ # This code comes directly from emerladCoder's github
	echo "Searching for and patching RPGM Plugins.js"
PATTERN='/];/i ,{"name":"Cheat_Menu","status":true,"description":"","parameters":{}}'
if [ -f "www/js/plugins.js" ]; then
	cp -v www/js/plugins.js www/js/plugins.js~ 2>/dev/null &&
		sed -i "$PATTERN" www/js/plugins.js
elif [ -f "js/plugins.js" ]; then
	cp -v js/plugins.js js/plugins.js~ 2>/dev/null &&
		sed -i "$PATTERN" js/plugins.js
else
    echo "No RPGM installation found."
fi
}

download_plugins(){
	curl -L \
  -o js/plugins/Cheat_Menu.css \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.css && \
curl -L \
  -o js/plugins/Cheat_Menu.js \
  https://raw.githubusercontent.com/emerladCoder/RPG-Maker-MV-Cheat-Menu-Plugin/refs/heads/master/Cheat_Menu/www/js/plugins/Cheat_Menu.js
}

patch_pluginsjs
download_plugins
