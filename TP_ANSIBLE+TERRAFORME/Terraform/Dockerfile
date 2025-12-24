FROM python:3.13-slim

# -------------------
# Installer les paquets nécessaires
# -------------------
RUN apt-get update && \
    apt-get install -y \
        nginx \
        openssh-server \
        sudo \
        vim \
        curl \
        git \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# -------------------
# Créer les dossiers nécessaires pour SSH
# -------------------
RUN mkdir -p /var/run/sshd

# Générer les clés SSH du serveur
RUN ssh-keygen -A

# -------------------
# Installer Python packages
# -------------------
RUN pip install --no-cache-dir requests docker

# -------------------
# Ajouter un utilisateur pour Ansible
# -------------------
RUN useradd -m ansible -s /bin/bash && \
    echo "ansible:ansible" | chpasswd && \
    usermod -aG sudo ansible

# -------------------
# Configurer SSH pour autoriser root login et ansible
# -------------------
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# -------------------
# Créer .ssh et générer une paire de clés pour ansible
# -------------------
RUN mkdir -p /home/ansible/.ssh && \
    ssh-keygen -t ed25519 -f /home/ansible/.ssh/id_ed25519 -N "" && \
    cat /home/ansible/.ssh/id_ed25519.pub >> /home/ansible/.ssh/authorized_keys && \
    chown -R ansible:ansible /home/ansible/.ssh && chmod 700 /home/ansible/.ssh && chmod 600 /home/ansible/.ssh/authorized_keys

# -------------------
# Exposer les ports SSH et HTTP
# -------------------
EXPOSE 22 80

# -------------------
# Lancer Nginx et SSH
# -------------------
CMD nginx -g 'daemon off;' & /usr/sbin/sshd -D
