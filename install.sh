#!/bin/bash


echo "====================================="
echo "    instalando aplicativos..."
echo "====================================="

# Verificar se o script está sendo executado como root
if [ "$(id -u)" != "0" ]; then
   echo "Este script precisa ser executado como root" 
   exit 1
fi

echo "Atualizando os repositórios..."
apt update


APPS_APT=(
    # Editores de texto/código
    "vim"
    "code"
    
    # Utilitários
    "htop"
    "git"
    "curl"
    "wget"
    
    # Outros
    "gimp"
    "flatpak"

)


APPS_FLATPAK=(
    "io.github.fsobolev.TimeSwitch"
    "com.spotify.Client"
    "com.discordapp.Discord"
    "app.zen_browser.zen"
    "com.bitwarden.desktop"

)

echo "instalando apps do repositório apt"
for app_apt in "${APPS_APT[@]}"; do
    echo "Instalando: $app_apt"
    apt install -y $app_apt
    
    if [ $? -eq 0 ]; then
        echo "✅ $app_apt instalado com sucesso!"
    else
        echo "❌ Falha ao instalar $app_apt"
    fi
done

flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "instalando apps do repositório flatpak"
for app_flatpak in "${APPS_FLATPAK[@]}"; do
    echo "Instalando: $app_flatpak"
    flatpak install -y flathub $app_flatpak
    
    if [ $? -eq 0 ]; then
        echo "✅ $app_flatpak instalado com sucesso!"
    else
        echo "❌ Falha ao instalar $app_flatpak"
    fi
done


# fazendo o download de arquivos .deb

wget -P /home/salesluis/Downloads https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb


cd /home/salesluis/Downloads
apt install ./*.deb

# Limpando pacotes não necessários
apt autoremove -y
apt clean

echo "Sistema limpo. Todas as instalações concluídas."
echo "====================================="
echo "    configurando docker"

# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

wget -P /home/salesluis/Downloads https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb

apt-get update
apt-get install /home/salesluis/Downloads/docker-desktop-amd64.deb

systemctl --user start docker-desktop
apt update -y
apt upgrade -y
docker compose version
docker version

