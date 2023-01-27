#!/bin/sh
rm -rf public
git checkout master
npm run build
cp -r public/* .
echo 'gpernelle.github.io' > CNAME
rm -rf public
git add -A .
git commit -a -m 'site update'
git push origin master
git checkout develop
