FROM nginx:alpine
# Copiamos el index.html al servidor web
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
# Usamos un comando de inicio que sobreescribe una variable en el HTML para mostrar el POD de balanceo
CMD ["/bin/sh", "-c", "sed -i \"s/POD_NAME/$(hostname)/g\" /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
