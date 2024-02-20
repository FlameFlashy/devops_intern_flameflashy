# Stage 1: Build Angular application
FROM node:18-alpine AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --prod

# Stage 2: Serve Angular application with Nginx
FROM nginx:1.21.4-alpine
COPY --from=build /app/dist/proj /usr/share/nginx/html/frontend
COPY frontend/nginx/configs/default.conf /etc/nginx/conf.d/default.conf
COPY frontend/nginx/nginx.conf /etc/nginx/nginx.conf
EXPOSE 4200
CMD ["nginx", "-g", "daemon off;"]