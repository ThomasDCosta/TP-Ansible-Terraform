#!/bin/bash
set -e
set -u

echo "=============================="
echo " Début de l'automatisation"
echo "=============================="


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chemins absolus
TERRAFORM_DIR="$SCRIPT_DIR/Terraform"
ANSIBLE_DIR="$SCRIPT_DIR/Ansible"



############################
# Terraform / Docker
############################
echo " Vérification de l'image Docker et des conteneurs"

cd "$TERRAFORM_DIR"

# Vérifier si l'image Docker existe
if [[ "$(docker images -q nginx_ssh_ansible 2> /dev/null)" == "" ]]; then
    echo " Image Docker introuvable. Construction..."
    docker build -t nginx_ssh_ansible .
else
    echo " Image Docker déjà existante"
fi

# Vérifier si Terraform doit être appliqué
if ! terraform show | grep -q "No state."; then
    echo " Terraform state trouvé, conteneurs existants"
else
    echo " Déploiement Terraform"
    terraform init
    terraform plan -out=tfplan
    terraform apply -auto-approve tfplan
fi

############################
#  Configuration SSH
############################
echo " Configuration SSH"

cd "$ANSIBLE_DIR"

# Générer une clé SSH si inexistante
if [ ! -f ~/.ssh/id_ed25519.pub ]; then
    echo " Clé SSH introuvable. Création..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
else
    echo " Clé SSH existante"
fi

# Copier la clé vers les conteneurs
for port in 2222 2223; do
    echo " Copie clé SSH sur le port $port"
    ssh-copy-id -i ~/.ssh/id_ed25519.pub -p "$port" ansible@127.0.0.1 || true
done

# Installer certificats Python (macOS)
if [ -f "/Applications/Python 3.14/Install Certificates.command" ]; then
    /Applications/Python\ 3.14/Install\ Certificates.command
fi

# rm -f ~/.ssh/known_hosts  # Décommenter si problème MITM

############################
# Déploiement Ansible
############################
echo " Déploiement Ansible"
ansible-playbook -i Inventory/hosts.ini playbooks/playbook.yaml

echo "=============================="
echo " Automatisation terminée !"
echo "=============================="
