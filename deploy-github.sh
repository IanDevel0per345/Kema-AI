#!/bin/bash
# Script para enviar o código para o GitHub Actions, que fará o build e deploy na Vercel

echo "🚀 Iniciando processo de envio para o GitHub Actions..."

# Verifica se tem arquivos para dar commit
if [ -z "$(git status --porcelain)" ]; then
  echo "✅ Não há alterações novas para enviar."
  exit 0
fi

# Adiciona todas as mudanças
git add .

# Pede mensagem de commit ou usa padrão
echo "💬 Digite a mensagem de commit (ou pressione Enter para 'Atualização de código'):"
read commit_message

if [ -z "$commit_message" ]; then
  commit_message="Atualização de código"
fi

# Faz o commit
git commit -m "$commit_message"

# Envia para o repositório no GitHub (disparando o Github Actions)
echo "📤 Enviando para o GitHub..."
git push origin main

echo "🎉 Enviado com sucesso! O GitHub Actions começará o pnpm build e deploy na Vercel agora."
