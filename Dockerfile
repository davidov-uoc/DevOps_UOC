FROM nginx:alpine
# Copiamos el index.html al servidor web
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
