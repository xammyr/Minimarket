# Etapa de construcción (Build)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
# Usamos compilación de producción (optimización, minificación, tree-shaking)
RUN npm run build --configuration=production

# Etapa de ejecución (Nginx) - Ultra ligero para servir estáticos
FROM nginx:alpine
# Copiamos la build de Angular a la carpeta de nginx
COPY --from=builder /app/dist/minimarket-frontend/browser /usr/share/nginx/html
# Copiamos una configuración personalizada de nginx (para rutas de Angular)
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
