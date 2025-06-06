FROM debian:wheezy
LABEL maintainer="security@example.com"

ENV DEBIAN_FRONTEND=noninteractive

# Configuration des sources d'archive
RUN sed -i 's|http://deb.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|http://security.debian.org|http://archive.debian.org|g' /etc/apt/sources.list && \
    sed -i '/wheezy-updates/d' /etc/apt/sources.list && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99ignore-valid-until && \
    echo 'Acquire::AllowInsecureRepositories "true";' >> /etc/apt/apt.conf.d/99ignore-valid-until

# Installation des paquets nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
    wget ca-certificates cups cups-client sudo netcat ruby && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV BASH_DEB_URL=http://snapshot.debian.org/archive/debian/20131013T214554Z/pool/main/b/bash/bash_4.2%2Bdfsg-1_amd64.deb
RUN wget -O /tmp/bash.deb "$BASH_DEB_URL"

# 3. Installation du paquet .deb téléchargé et blocage de la version pour empêcher les mises à jour.
RUN dpkg -i /tmp/bash.deb && \
    apt-mark hold bash && \
    rm /tmp/bash.deb

# 4. Vérification que la version de Bash installée est bien vulnérable.
#    Cette commande échouera si le mot "VULNERABLE" n'est pas affiché, arrêtant la construction de l'image.
RUN echo "--- Verifying Shellshock vulnerability ---" && \
    env x='() { :;}; echo VULNERABLE' bash -c "echo Test" | grep VULNERABLE && \
    echo "--- Verification successful: Bash is VULNERABLE ---"

# Création de l'utilisateur admin
RUN useradd -m -s /bin/bash admin && \
    echo 'admin:hello' | chpasswd && \
    usermod -aG lpadmin,sudo admin

# Configuration CUPS simplifiée
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Listen \/run\/cups\/cups.sock/# Listen \/run\/cups\/cups.sock/' /etc/cups/cupsd.conf

# Configuration des permissions pour l'interface web
RUN cat >> /etc/cups/cupsd.conf << EOF

# Configuration pour tests de sécurité
WebInterface Yes
DefaultAuthType Basic

# Autoriser l'accès depuis n'importe où
<Location />
  Allow all
</Location>

<Location /admin>
  Allow all
  AuthType Basic
  Require user admin
</Location>

<Location /admin/conf>
  Allow all
  AuthType Basic  
  Require user admin
</Location>
EOF

# Créer un filtre vulnérable pour Shellshock
RUN mkdir -p /usr/lib/cups/filter/ && \
    cat > /usr/lib/cups/filter/vulnfilter << 'EOF'
#!/bin/bash
# Filtre vulnérable pour tests Shellshock
echo "Content-type: text/plain"
echo ""
echo "Filter processing: $*"
# Vulnérabilité intentionnelle - exécute des commandes via variables d'environnement
eval "echo Processing job: $CUPS_SERVERBIN"
EOF

RUN chmod +x /usr/lib/cups/filter/vulnfilter

# Démarrer CUPS en mode debug pour plus de logs
EXPOSE 631

# Script de démarrage
RUN cat > /start.sh << 'EOF'
#!/bin/bash
echo "Démarrage du serveur CUPS vulnérable..."
echo "Interface web accessible sur http://localhost:631"
echo "Utilisateur: admin / Mot de passe: hello"

# Démarrer CUPS
/usr/sbin/cupsd -f
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"]
