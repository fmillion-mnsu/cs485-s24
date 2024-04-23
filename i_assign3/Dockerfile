FROM nginx:alpine

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT [ "/entrypoint.sh" ]