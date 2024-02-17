# Stage 1: Build Angular application
FROM node:18-alpine AS build-stage
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --prod

# Stage 2: Serve Angular application with Nginx
FROM nginx:1.21.4-alpine
COPY --from=build-stage /app/dist/proj /usr/share/nginx/html
EXPOSE 4200
CMD ["nginx", "-g", "daemon off;"]