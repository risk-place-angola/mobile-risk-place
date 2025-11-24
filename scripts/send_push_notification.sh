#!/bin/bash

# Script para enviar notificações push via FCM
# Para dispositivos físicos e simuladores
# 
# USO:
# 1. Obtenha o FCM Token do dispositivo (aparece nos logs como [FCMService] FCM Token: ...)
# 2. Obtenha a Server Key do Firebase Console:
#    - Vá para Firebase Console > Project Settings > Cloud Messaging
#    - Copie a "Server Key" (Legacy)
# 3. Execute: ./scripts/send_push_notification.sh <FCM_TOKEN> <SERVER_KEY>

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar argumentos
if [ "$#" -lt 1 ]; then
    echo -e "${RED}❌ Erro: FCM Token necessário${NC}"
    echo ""
    echo -e "${YELLOW}USO:${NC}"
    echo "  $0 <FCM_TOKEN> [SERVER_KEY]"
    echo ""
    echo -e "${YELLOW}Como obter o FCM Token:${NC}"
    echo "  1. Execute o app no dispositivo físico"
    echo "  2. Verifique os logs: [FCMService] FCM Token: ..."
    echo "  3. Copie o token completo"
    echo ""
    echo -e "${YELLOW}Como obter a Server Key:${NC}"
    echo "  1. Vá para Firebase Console"
    echo "  2. Project Settings > Cloud Messaging"
    echo "  3. Copie a 'Server Key' (Legacy)"
    echo ""
    exit 1
fi

FCM_TOKEN="$1"
SERVER_KEY="${2:-}"

# Se não forneceu a server key, tentar ler de variável de ambiente
if [ -z "$SERVER_KEY" ]; then
    if [ -z "$FIREBASE_SERVER_KEY" ]; then
        echo -e "${RED}❌ Erro: Server Key não fornecida${NC}"
        echo ""
        echo "Opções:"
        echo "  1. Passe como segundo argumento: $0 <TOKEN> <SERVER_KEY>"
        echo "  2. Defina a variável de ambiente: export FIREBASE_SERVER_KEY='sua_key'"
        echo ""
        exit 1
    fi
    SERVER_KEY="$FIREBASE_SERVER_KEY"
fi

# Dados da notificação
TITLE="Teste Push Notification"
BODY="Esta é uma notificação de teste enviada via FCM API"

echo -e "${GREEN}📱 Enviando notificação push...${NC}"
echo -e "${YELLOW}Token:${NC} ${FCM_TOKEN:0:20}..."
echo ""

# Enviar notificação via FCM API
RESPONSE=$(curl -s -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=$SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"to\": \"$FCM_TOKEN\",
    \"notification\": {
      \"title\": \"$TITLE\",
      \"body\": \"$BODY\",
      \"sound\": \"default\",
      \"badge\": 1
    },
    \"data\": {
      \"click_action\": \"FLUTTER_NOTIFICATION_CLICK\",
      \"test\": \"true\",
      \"timestamp\": \"$(date +%s)\"
    },
    \"priority\": \"high\"
  }")

# Verificar resposta
if echo "$RESPONSE" | grep -q "\"success\":1"; then
    echo -e "${GREEN}✅ Notificação enviada com sucesso!${NC}"
    echo ""
    echo -e "${GREEN}Resposta:${NC}"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}❌ Erro ao enviar notificação${NC}"
    echo ""
    echo -e "${RED}Resposta:${NC}"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
    echo ""
    echo -e "${YELLOW}Possíveis causas:${NC}"
    echo "  • Server Key inválida"
    echo "  • FCM Token expirado ou inválido"
    echo "  • App não está rodando ou sem permissão de notificações"
    exit 1
fi
