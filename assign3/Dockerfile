FROM nginx:alpine

COPY group.tx[t] entrypoint.sh /
COPY default.conf /etc/nginx/conf.d/
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]
