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
pacman -Syu --noconfirm

APPS_PACMAN=(
    # Editores de texto/código
    "vim"
    
    # Utilitários
    "nodejs"
    "htop"
    "git"
    "curl"
    "wget"
    
    # Outros
    "flatpak"
)

APPS_AUR=(
    "visual-studio-code-bin"
    "dbeaver"
)

APPS_FLATPAK=(
    "io.github.fsobolev.TimeSwitch"
    "com.spotify.Client"
    "com.discordapp.Discord"
    "com.bitwarden.desktop"
    "md.obsidian.Obsidian"
    "com.google.Chrome"
    "org.chromium.Chromium"
    "com.getpostman.Postman"
)

echo "Instalando apps do repositório oficial do Arch"
for app_pacman in "${APPS_PACMAN[@]}"; do
    echo "Instalando: $app_pacman"
    pacman -S --noconfirm $app_pacman
    
    if [ $? -eq 0 ]; then
        echo "✅ $app_pacman instalado com sucesso!"
    else
        echo "❌ Falha ao instalar $app_pacman"
    fi
done

# Verificar se yay está instalado, se não, instalar
if ! command -v yay &> /dev/null; then
    echo "Instalando yay (AUR helper)..."
    pacman -S --noconfirm base-devel git
    
    # Criar usuário temporário para instalar yay (não pode ser feito como root)
    useradd -m -G wheel -s /bin/bash temp_user
    echo "temp_user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    
    su - temp_user -c "
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
    "
    
    # Remover usuário temporário
    userdel -r temp_user
    sed -i '/temp_user ALL=(ALL) NOPASSWD: ALL/d' /etc/sudoers
fi

echo "Instalando apps do AUR"
for app_aur in "${APPS_AUR[@]}"; do
    echo "Instalando: $app_aur"
    sudo -u nobody yay -S --noconfirm $app_aur
    
    if [ $? -eq 0 ]; then
        echo "✅ $app_aur instalado com sucesso!"
    else
        echo "❌ Falha ao instalar $app_aur"
    fi
done

# Configurar Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo "Instalando apps do repositório flatpak"
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
pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || echo "Nenhum pacote órfão encontrado"
pacman -Scc --noconfirm

echo "Sistema limpo. Todas as instalações concluídas."
echo "====================================="
echo "    configurando docker"

# Instalar Docker
pacman -S --noconfirm docker docker-compose

# Habilitar e iniciar o serviço Docker
systemctl enable docker
systemctl start docker

# Instalar Docker Desktop (via AUR)
echo "Instalando Docker Desktop..."
sudo -u nobody yay -S --noconfirm docker-desktop

# Adicionar usuário atual ao grupo docker (substitua 'username' pelo usuário desejado)
echo "Adicionando usuário ao grupo docker..."
echo "ATENÇÃO: Execute 'usermod -aG docker SEU_USUARIO' manualmente após o script"

# Atualizar sistema
pacman -Syu --noconfirm

echo "Verificando instalações do Docker..."
docker compose version
docker version

echo "====================================="
echo "Instalação concluída!"
echo "LEMBRE-SE:"
echo "1. Execute 'usermod -aG docker SEU_USUARIO' para adicionar seu usuário ao grupo docker"
echo "2. Faça logout e login novamente para aplicar as mudanças de grupo"
echo "3. Para iniciar o Docker Desktop: systemctl --user start docker-desktop"
echo "====================================="
