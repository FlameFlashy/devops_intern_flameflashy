# Stage 1: Build Angular application
FROM node:18-alpine AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --prod --outputPath=./dist/frontend


# Stage 2: Serve Angular application with Nginx
FROM nginx:1.25.4-alpine
COPY --from=build-stage /app/dist/frontend/ /usr/share/nginx/html/frontend
COPY /nginx/nginx.conf /etc/nginx/conf.d/nginx.conf
EXPOSE 4200
CMD ["nginx", "-g", "daemon off;"]