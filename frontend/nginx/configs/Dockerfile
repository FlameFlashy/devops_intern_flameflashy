FROM nginx:1.21.4-alpine

COPY frontend/nginx/configs/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]