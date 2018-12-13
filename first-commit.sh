#!/bin/sh

echo "# XLAT1" >> README.md
git init
git add .
git commit -m "13 Dec 2018 Initial add"
git remote add origin https://github.com/softwareguycoder/XLAT1.git
git push -u origin master

