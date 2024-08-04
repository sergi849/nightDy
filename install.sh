#!/bin/bash

# Verifikasi apakah user yang menjalankan script adalah root user atau bukan
if (( $EUID != 0 )); then
    echo "Ejecute como root"
    exit
fi

clear

# Fungsi untuk membuat backup dari directory pterodactyl
installTheme(){
    cd /var/www/
    tar -cvf nightDy.tar.gz pterodactyl
    echo "Instalando el tema, espera..."
    cd /var/www/pterodactyl
    rm -r nightDy
    git clone https://github.com/sergi849/nightDy.git
    cd nightDy
    rm /var/www/pterodactyl/resources/scripts/mufniDev.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv mufniDev.css /var/www/pterodactyl/resources/scripts/mufniDev.css
    cd /var/www/pterodactyl

    # Install dependencies
    curl -sL https://deb.nodesource.com/setup_14.x | bash -
    apt update
    apt install -y nodejs

    npm i -g yarn
    yarn

    cd /var/www/pterodactyl
    yarn build:production
    php artisan optimize:clear
}

# Fungsi untuk menanyakan user apakah yakin ingin menginstall theme atau tidak
installThemeQuestion(){
    while true; do
        read -p "¿Quieres instalar este tema [y/n]? " yatidak
        case $yatidak in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Por favor responda y(sí) o n(no).";;
        esac
    done
}

# Fungsi untuk memperbaiki panel jika terjadi error pada saat menginstall theme
repair(){
    bash <(curl https://raw.githubusercontent.com/sergi849/nightDy/main/repair.sh)
}

# Fungsi untuk mengembalikan backup dari directory pterodactyl
restoreBackUp(){
    echo "Restaurando la copia de seguridad..."
    cd /var/www/
    tar -xvf nightDy.tar.gz
    rm nightDy.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    php artisan optimize:clear
}

# Menampilkan menu pilihan
echo "Copyright © nightDy | by sergi849 & itzrauh"
echo "Este script es 100% GRATIS, puedes editarlo y distribuirlo."
echo "Pero no puedes comprar ni vender este script sin el permiso del desarrollador."
echo "#RespectTheDevelopers"
echo ""
echo "Discord:-"
echo "GitHub: https://github.com/sergi8449"
echo ""
echo "[1] Poner Tema"
echo "[2] Poner Backup"
echo "[3] Reparar Panel (Para arreglar algun bug de instalación o error)"
echo "[4] Cerrar"

# Meminta user untuk memilih pilihan
read -p "Por favor, introduzca un número: " choice

# Menjalankan pilihan yang dipilih oleh user
if [ $choice == "1" ]; then
    installThemeQuestion
fi

if [ $choice == "2" ]; then
    restoreBackUp
fi

if [ $choice == "3" ]; then
    repair
fi

if [ $choice == "4" ]; then
    exit
fi
