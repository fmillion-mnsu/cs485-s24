#!/bin/sh

# generate a simple html file based on environment vars

echo "<html><head><title>$HOSTNAME</title></head>" > /usr/share/nginx/html/index.html

echo "<body><h1>Hello, I'm ${HOSTNAME}!</h1>" >> /usr/share/nginx/html/index.html

echo "<pre>" >> /usr/share/nginx/html/index.html
# generate an environment variable listing
env | while IFS= read -r line; do
    echo "$line" >> /usr/share/nginx/html/index.html
done

echo "</pre>" >> /usr/share/nginx/html/index.html

echo "<hr /><h6>CS485 Demonstration</h6></body></html>" >> /usr/share/nginx/html/index.html

# run nginx in the foreground
exec nginx -g 'daemon off;'
