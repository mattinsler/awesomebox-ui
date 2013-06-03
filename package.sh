#!/bin/sh

rm -rf awesomebox.app
cp -r node-webkit.app awesomebox.app
mkdir awesomebox.app/Contents/Resources/app.nw
cp -r {app-templates,components,index.html,javascripts,node_modules,package.json,stylesheets,templates} awesomebox.app/Contents/Resources/app.nw/
