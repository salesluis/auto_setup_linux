#!/bin/bash
echo "====================================="
echo "  Criando laboratorio e ambiente...  "
echo "====================================="

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22
node -v
nvm current 
npm -v

mkdir ~ 
mkidir dev && cd dev
mkdir projects estudies


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
    "vim"
    "nodejs"
    "htop"
    "git"
    "curl"
    "wget"
    "flatpak"
    "gnome-tweaks"
)


APPS_FLATPAK=(
    "com.visualstudio.code"
    "io.github.fsobolev.TimeSwitch"
    "com.spotify.Client"
    "com.discordapp.Discord"
    "io.dbeaver.DBeaverCommunit"
    "com.bitwarden.desktop"
    "flathub md.obsidian.Obsidian"
    "com.google.Chrome"
    "com.getpostman.Postman"
    "com.jgraph.drawio.desktop"
    "com.jetbrains.Rider"
    "com.jgraph.drawio.desktop"
    "com.mattjakeman.ExtensionManager"
    "org.gnome.Extensions"
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


# Limpando pacotes não necessários
apt autoremove -y
apt clean

wget https://mega.nz/linux/repo/xUbuntu_24.10/amd64/megasync-xUbuntu_24.10_amd64.deb && sudo apt install "$PWD/megasync-xUbuntu_24.10_amd64.deb"

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

