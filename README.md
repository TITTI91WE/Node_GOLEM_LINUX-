# Scarica lo script
nano install-golem.sh

# Copia e incolla lo script sopra, poi salva (Ctrl+X, Y, Enter)

# Rendi eseguibile
chmod +x install-golem.sh

# Esegui
./install-golem.sh

# 1. Avvia Golem per la prima volta
golemsp run

# 2. Inserisci quando richiesto:
# Node name: treep-mini1
# Wallet: 0xb85e31e4c7d87d41d01ab32f50eeb448fb796b90

# 3. Dopo che si avvia, premi Ctrl+C

# 4. Applica i prezzi competitivi
./configure-golem.sh

# 5. Riavvia con systemd
sudo systemctl start golem-provider
sudo systemctl enable golem-provider

# Controlla stato
sudo systemctl status golem-provider

# Monitora
./monitor-golem.sh
