#!/bin/bash
# Script installazione Golem per Mini PC
# Configurato per berta - Mini PC #1

set -e  # Esci se ci sono errori

# Colori per output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Configurazione
WALLET_ADDRESS="0xb85e31e4c7d87d41d01ab32f50eeb448fb796b90"
NODE_NAME="treep-mini1"
CPU_PRICE="0.005"
ENV_PRICE="0.05"
START_FEE="0.0"

echo -e "${GREEN}=== Installazione Golem Mini PC #1 ===${NC}"
echo -e "Node name: ${YELLOW}${NODE_NAME}${NC}"
echo -e "Wallet: ${YELLOW}${WALLET_ADDRESS}${NC}"

# 1. Aggiorna sistema
echo -e "\n${YELLOW}1. Aggiornamento sistema...${NC}"
sudo apt update && sudo apt upgrade -y

# 2. Installa dipendenze
echo -e "\n${YELLOW}2. Installazione dipendenze...${NC}"
sudo apt install -y curl wget git

# 3. Scarica e installa Golem
echo -e "\n${YELLOW}3. Download Golem...${NC}"
curl -sSf https://join.golem.network/as-provider | bash -

# 4. Aggiungi al PATH
echo -e "\n${YELLOW}4. Configurazione PATH...${NC}"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# 5. Crea script di configurazione
echo -e "\n${YELLOW}5. Creazione script configurazione...${NC}"
cat > ~/configure-golem.sh << 'EOF'
#!/bin/bash
# Configurazione automatica prezzi

echo "Attendere che Golem sia completamente avviato..."
sleep 30

# Configura prezzi ultra-competitivi
golemsp settings set --cpu-per-hour 0.005
golemsp settings set --env-per-hour 0.05
golemsp settings set --starting-fee 0.0

# Mostra configurazione
echo "=== Configurazione Prezzi ==="
golemsp settings show

echo "=== Stato Provider ==="
golemsp status
EOF

chmod +x ~/configure-golem.sh

# 6. Crea script di monitoraggio
echo -e "\n${YELLOW}6. Creazione script monitoraggio...${NC}"
cat > ~/monitor-golem.sh << 'EOF'
#!/bin/bash
# Monitoraggio continuo Golem

while true; do
    clear
    echo "=== Monitor Golem - $(date) ==="
    echo ""
    golemsp status
    echo ""
    echo "=== Ultime Proposte ==="
    grep "Got proposal" ~/.local/share/ya-provider/ya-provider_rCURRENT.log 2>/dev/null | tail -5 || echo "Nessuna proposta ancora"
    echo ""
    echo "=== Agreement ==="
    grep -i "agreement" ~/.local/share/ya-provider/ya-provider_rCURRENT.log 2>/dev/null | tail -3 || echo "Nessun agreement ancora"
    echo ""
    echo "Premi Ctrl+C per uscire - Aggiornamento ogni 30 secondi"
    sleep 30
done
EOF

chmod +x ~/monitor-golem.sh

# 7. Crea servizio systemd
echo -e "\n${YELLOW}7. Creazione servizio systemd...${NC}"
sudo tee /etc/systemd/system/golem-provider.service > /dev/null << EOF
[Unit]
Description=Golem Provider
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/.local/bin/golemsp run
Restart=always
RestartSec=30
Environment="PATH=$HOME/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
EOF

# 8. Abilita firewall
echo -e "\n${YELLOW}8. Configurazione firewall...${NC}"
sudo ufw allow 11500/tcp
sudo ufw allow 11500/udp
sudo ufw --force enable

# 9. Istruzioni finali
echo -e "\n${GREEN}=== Installazione Completata! ===${NC}"
echo ""
echo -e "${YELLOW}PROSSIMI PASSI:${NC}"
echo ""
echo "1. Avvia Golem manualmente per la prima configurazione:"
echo -e "   ${GREEN}golemsp run${NC}"
echo ""
echo "2. Quando richiesto, inserisci:"
echo -e "   Node name: ${GREEN}${NODE_NAME}${NC}"
echo -e "   Wallet: ${GREEN}${WALLET_ADDRESS}${NC}"
echo ""
echo "3. Dopo l'avvio iniziale, premi Ctrl+C e esegui:"
echo -e "   ${GREEN}./configure-golem.sh${NC}"
echo ""
echo "4. Per avvio automatico al boot:"
echo -e "   ${GREEN}sudo systemctl enable golem-provider${NC}"
echo -e "   ${GREEN}sudo systemctl start golem-provider${NC}"
echo ""
echo "5. Per monitorare:"
echo -e "   ${GREEN}./monitor-golem.sh${NC}"
echo ""
echo -e "${YELLOW}NOTA:${NC} Usa un nome diverso per ogni mini PC!"
echo "Mini PC #1: treep-mini1"
echo "Mini PC #2: treep-mini2"
echo "Mini PC #3: treep-mini3, ecc..."

# Salva info installazione
cat > ~/golem-info.txt << EOF
=== GOLEM INSTALLATION INFO ===
Date: $(date)
Node Name: ${NODE_NAME}
Wallet: ${WALLET_ADDRESS}
Prices: CPU=${CPU_PRICE} GLM/h, ENV=${ENV_PRICE} GLM/h
Version: $(golemsp --version 2>/dev/null || echo "Da verificare dopo primo avvio")

Comandi utili:
- Stato: golemsp status
- Log: tail -f ~/.local/share/ya-provider/ya-provider_rCURRENT.log
- Riavvia: sudo systemctl restart golem-provider
- Monitor: ./monitor-golem.sh
EOF

echo -e "\n${GREEN}Info salvate in ~/golem-info.txt${NC}"
