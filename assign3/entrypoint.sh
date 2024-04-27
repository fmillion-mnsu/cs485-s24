#!/bin/sh

# generate a simple html file based on environment vars

if [ ! -f "/group.txt" ]; then
    echo "<html><body>Whoops! You didn't provide a group.txt file for your group! Try to build and push your container again, and then re-deploy your deployment.</body></html>" > /usr/share/nginx/html/index.html
    exec nginx -g 'daemon off;'
    exit 0
fi

echo "<html><head><title>$HOSTNAME</title></head>" > /usr/share/nginx/html/index.html

echo "<body><h1>Hello, I'm ${HOSTNAME}!</h1>" >> /usr/share/nginx/html/index.html

while IFS= read -r line; do
    echo "<p>$line</p>" >> /usr/share/nginx/html/index.html
done < /group.txt

echo "<hr /><pre>" >> /usr/share/nginx/html/index.html
# generate an environment variable listing
env | while IFS= read -r line; do
    echo "$line" >> /usr/share/nginx/html/index.html
done

echo "</pre>" >> /usr/share/nginx/html/index.html

echo "<hr /><h6>CS485 Group Assignment 3</h6></body></html>" >> /usr/share/nginx/html/index.html

# run nginx in the foreground
exec nginx -g 'daemon off;'
