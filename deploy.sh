#!/bin/zsh

if [ "`git status -s`" ]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public

echo "Generating site"
env HUGO_ENV="production" hugo -v 

echo "Push to server"
scp -r public script.money:/var/www/blog