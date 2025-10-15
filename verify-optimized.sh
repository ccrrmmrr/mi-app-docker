#!/bin/bash
echo "🚀 VERIFICACIÓN DE IMAGEN OPTIMIZADA"
echo "===================================="

# Verificar que la imagen existe
if ! docker images mi-app:optimized | grep -q "mi-app"; then
    echo "❌ Imagen optimizada no encontrada, construyendo..."
    docker build -t mi-app:optimized ./backend
fi

echo ""
echo "📊 COMPARACIÓN DE TAMAÑOS:"
echo "---------------------------"
docker images mi-app:baseline --format "BASELINE:  {{.Repository}}:{{.Tag}} -> {{.Size}}" 2>/dev/null || echo "BASELINE: No encontrada"
docker images mi-app:optimized --format "OPTIMIZED: {{.Repository}}:{{.Tag}} -> {{.Size}}"

echo ""
echo "👤 VERIFICACIÓN DE SEGURIDAD:"
echo "Usuario: $(docker run --rm mi-app:optimized whoami)"
echo "UID: $(docker run --rm mi-app:optimized id)"

echo ""
echo "🔍 TEST DE FUNCIONALIDAD:"
docker run -d --name verify-opt -p 3001:3000 mi-app:optimized
sleep 5
echo "Health Check:"
curl -s http://localhost:3001/health | jq . 2>/dev/null || curl -s http://localhost:3001/health
echo ""
echo "Home:"
curl -s http://localhost:3001/ | jq . 2>/dev/null || curl -s http://localhost:3001/
docker stop verify-opt >/dev/null 2>&1
docker rm verify-opt >/dev/null 2>&1

echo ""
echo "🛡️ ESCANEO DE VULNERABILIDADES:"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --severity CRITICAL,HIGH --format table mi-app:optimized

echo ""
echo "✅ VERIFICACIÓN COMPLETADA!"
