#!/bin/bash
echo "🚀 Iniciando a instalação do Ecossistema AI no Termux..."

# 1. Atualiza o sistema e instala pacotes base
pkg update -y && pkg upgrade -y
pkg install proot-distro git curl wget jq unzip -y

# 2. Instala a imagem base do Ubuntu
echo "📦 Instalando o Ubuntu (proot-distro)..."
proot-distro install ubuntu

# 3. Instala o Bun, Ollama e Node.js dentro do Ubuntu
echo "⚙️ Configurando o Ubuntu interno..."
proot-distro login ubuntu -- bash -c "
  # Instala o Bun
  curl -fsSL https://bun.sh/install | bash
  
  # Instala o Ollama (para rodar os modelos locais)
  curl -fsSL https://ollama.com/install.sh | sh
"

# 4. Baixa o modelo Gemma3 4b no Ollama
echo "🧠 Baixando o modelo Gemma3 4b (Isso pode demorar dependendo da internet)..."
proot-distro login ubuntu -- bash -c "
  nohup ollama serve > /dev/null 2>&1 & 
  sleep 5
  ollama pull gemma
"

echo "✅ Instalação concluída! O seu celular agora tem Ubuntu, Bun e um Motor de Inteligência Artificial Local."
