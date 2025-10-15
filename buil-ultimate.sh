#!/bin/bash
echo "🚀 CONSTRUYENDO IMAGEN ULTRA-OPTIMIZADA"
echo "========================================"

# Usar BuildKit para mejor performance
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
docker-compose down -v
docker rmi mi-app:ultimate 2>/dev/null || true

# Construir con todas las optimizaciones
echo "📦 Construyendo imagen ultra-optimizada..."
docker build \
    --tag mi-app:ultimate \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    ./backend

if [ $? -ne 0 ]; then
    echo "❌ Error en la construcción"
    exit 1
fi

# Mostrar información de la imagen
echo ""
echo "✅ CONSTRUCCIÓN EXITOSA!"
echo ""
echo "📊 INFORMACIÓN DE LA IMAGEN:"
docker images mi-app:ultimate --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

echo ""
echo "🏷️  LABELS DE METADATA:"
docker inspect mi-app:ultimate --format='{{range $k, $v := .Config.Labels}}{{$k}}={{$v}}{{"\n"}}{{end}}'

echo ""
echo "👤 VERIFICACIÓN DE SEGURIDAD:"
echo "Usuario: $(docker run --rm mi-app:ultimate whoami)"
echo "UID: $(docker run --rm mi-app:ultimate id)"

echo ""
echo "🔍 TESTEANDO FUNCIONALIDAD..."
docker run -d --name ultimate-test -p 3002:3000 mi-app:ultimate
sleep 5
echo "Health check:"
curl -s http://localhost:3002/health | jq . 2>/dev/null || curl -s http://localhost:3002/health
docker stop ultimate-test >/dev/null 2>&1
docker rm ultimate-test >/dev/null 2>&1

echo ""
echo "🛡️ ANALIZANDO VULNERABILIDADES..."
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity CRITICAL,HIGH --format table mi-app:ultimate

echo ""
echo "📈 COMPARACIÓN FINAL:"
docker images mi-app:baseline --format "BASELINE:  {{.Repository}}:{{.Tag}} -> {{.Size}}" 2>/dev/null || echo "BASELINE: No encontrada"
docker images mi-app:optimized --format "OPTIMIZED: {{.Repository}}:{{.Tag}} -> {{.Size}}" 2>/dev/null || echo "OPTIMIZED: No encontrada"
docker images mi-app:ultimate --format "ULTIMATE:  {{.Repository}}:{{.Tag}} -> {{.Size}}"

echo ""
echo "🎯 OPTIMIZACIÓN ULTIMA COMPLETADA!"
