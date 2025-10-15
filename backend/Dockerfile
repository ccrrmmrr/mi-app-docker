# 🚀 DOCKERFILE OPTIMIZADO - SEGURIDAD Y PERFORMANCE
# ==================================================

# STAGE 1: Builder stage
FROM node:18-alpine AS builder

# Metadata labels
LABEL stage="builder" \
      maintainer="cmartinez" \
      description="Build stage for Node.js application"

WORKDIR /app

# Copiar archivos de dependencias primero (optimización de cache)
COPY package.json package-lock.json ./

# Instalar todas las dependencias (incluyendo dev para construcción)
RUN npm ci --include=dev

# Copiar código fuente
COPY . .

# STAGE 2: Production stage
FROM node:18-alpine AS production

# Metadata labels para producción
LABEL maintainer="cmartinez" \
      version="1.0-optimizado" \
      description="Aplicación Node.js optimizada con Docker" \
      security.scan="trivy" \
      security.non-root="true" \
      security.base-image="alpine" \
      build.timestamp="{{ now }}" \
      org.opencontainers.image.source="https://github.com/tu-usuario/mi-app-docker"

# Variables de entorno
ENV NODE_ENV=production \
    PORT=3000 \
    NODE_OPTIONS="--max-old-space-size=512" \
    NPM_CONFIG_LOGLEVEL=warn \
    NPM_CONFIG_AUDIT=false \
    NPM_CONFIG_FUND=false

# Instalar solo paquetes necesarios y limpiar cache
RUN apk update && apk upgrade --no-cache && \
    apk add --no-cache tini curl && \
    rm -rf /var/cache/apk/* /tmp/*

WORKDIR /app

# Crear usuario non-root
RUN addgroup -g 1001 -S appuser && \
    adduser -S appuser -u 1001 -G appuser

# Copiar solo lo necesario desde el builder stage
COPY --from=builder --chown=appuser:appuser /app/node_modules ./node_modules
COPY --from=builder --chown=appuser:appuser /app/package.json ./
COPY --from=builder --chown=appuser:appuser /app/server.js ./

# Cambiar permisos y usuario
#RUN chown -R appuser:appuser /app && \
#    chmod -R 755 /app && \
#    chmod -R +r /app

USER appuser

# Health check mejorado
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Exponer puerto
EXPOSE 3000

# Usar tini como init system para manejar señales correctamente
ENTRYPOINT ["/sbin/tini", "--"]

# Comando de ejecución
CMD ["node", "server.js"]
