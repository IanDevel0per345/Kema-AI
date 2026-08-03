#!/bin/bash

# 1. Permissão de armazenamento e pacotes essenciais
echo "📱 Preparando o Termux..."
termux-setup-storage
pkg update -y && pkg upgrade -y
pkg install proot-distro git curl wget jq unzip -y

# 2. Clona o repositório
echo "📥 Clonando o projeto Kortix/Kema-AI..."
git clone https://github.com/IanDevel0per345/Kema-AI.git
cd Kema-AI

# 3. Instala a imagem base do Ubuntu
echo "📦 Instalando o Ubuntu interno (proot-distro)..."
proot-distro install ubuntu

# 4. Configura tudo dentro do Ubuntu com um único comando gigante
echo "⚙️ Instalando ferramentas e subindo servidores no Ubuntu..."
proot-distro login ubuntu -- bash -c "
  # Atualiza pacotes internos
  apt update && apt install curl wget git -y

  # Instala Bun
  curl -fsSL https://bun.sh/install | bash
  export PATH=\"\$HOME/.bun/bin:\$PATH\"

  # Instala Ollama
  curl -fsSL https://ollama.com/install.sh | sh

  # Instala Cloudflared (para o Túnel)
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64
  chmod +x cloudflared-linux-arm64

  # Liga o servidor Ollama em segundo plano e baixa o modelo gemma
  echo '🧠 Preparando IA (Ollama + Gemma)...'
  nohup ollama serve > ollama.log 2>&1 & 
  sleep 5
  # ollama pull gemma (descomente esta linha para baixar na primeira vez, pode demorar muito)

  # Instala dependencias do backend
  echo '📦 Instalando pacotes do backend (Bun)...'
  # Busca a raiz do projeto (onde está o package.json principal)
  cd \$(find / -name Kema-AI -type d 2>/dev/null | head -n 1)
  
  # Instala as dependências de todo o monorepo
  bun install

  echo '🚀 Ligando apenas a API...'
  # Roda apenas o backend (dev:api)
  nohup bun run dev:api > api.log 2>&1 &

  # Liga o Cloudflare tunnel apontando pra API
  echo '🌐 Criando túnel público...'
  nohup /root/cloudflared-linux-arm64 tunnel --url http://localhost:8008 > /root/tunnel.log 2>&1 &

  # Espera o Cloudflare gerar o link e exibe na tela
  sleep 10
  echo '==================================================='
  echo '✅ TUDO PRONTO E RODANDO!'
  echo '🔗 Seu link da Vercel (NEXT_PUBLIC_BACKEND_URL) é:'
  grep -o 'https://.*\.trycloudflare\.com' /root/tunnel.log
  echo '==================================================='
"
