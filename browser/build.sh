#!/usr/bin/env bash
PUBLICTARGET="../webclient-deployed"
OFFLINE="${PUBLICTARGET}/offline-assets"


echo -n "Killing off old cruft..."
rm -rf ${PUBLICTARGET}/*
echo " done"

echo -n "Copying in static files..."
mkdir -p ${OFFLINE}
rsync -a static/ ${OFFLINE}/
echo " done"

echo -n "Compiling JavaScript to CommonJS..."
pakmanager build > /dev/null 2>&1
echo " done"

echo -n "Compiling Jade to HTML..."
jade *.jade > /dev/null
echo " done"

echo -n "Compiling LESS to CSS and minifying..."
lessc style.less > style.css #| cleancss -o style.css
echo " done"

echo -n "Moving packaged files..."
mv *.css ${OFFLINE}/
mv index.html ${PUBLICTARGET}/
mv *.html ${OFFLINE}/
mv pakmanaged.js ${OFFLINE}/
#cp -R ./public/ ./windows/
echo " done"

echo -n "Writing cache manifest..."

cat > ${PUBLICTARGET}/main.appcache <<HEREDOCEND
CACHE MANIFEST
# This is the cache manifest for the WebApps Center

# version `date +%s`

CACHE:
# Pages:
/offline-assets/offline.html

# JS Resources:
/offline-assets/pakmanaged.js

# CSS:
/offline-assets/style.css

# Images:
/offline-assets/images/header_zebra.png
/offline-assets/images/loading.gif
/offline-assets/images/logo.png
/offline-assets/images/menu_bg.png
/offline-assets/images/delete-x.png
/offline-assets/images/error.png

# Fonts:
/offline-assets/fonts/opensans-bold.ttf
/offline-assets/fonts/opensans-extrabold.ttf
/offline-assets/fonts/opensans.ttf
/offline-assets/fonts/play.ttf

FALLBACK:
/offline-assets/offline.html

NETWORK:
http://apps.spotterrf.com:3999/
http://apps.spotterrf.com/
http://norman.spotter360.org:5984/
# http://hurpdurp.com:3999/
# http://hurpdurp.com/
# http://hurpdurp.iriscouch.com/
http://localhost:7770/alive
http://localhost:7770/installed
http://localhost:7770/applist
http://localhost:7770/install/
http://localhost:7770/delete/
HEREDOCEND

echo " done"
