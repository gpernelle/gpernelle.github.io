rm -rf public
git branch -f master
git checkout master
git reset --hard origin/develop
npm run build
cp -r public/* .
echo 'gpernelle.github.io' > CNAME
rm -rf public
git add -A .
git commit -a -m 'site update'
git push origin master --force
git checkout develop
git rev-parse --abbrev-ref HEAD