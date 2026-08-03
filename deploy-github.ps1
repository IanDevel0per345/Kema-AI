# Script para enviar o código para o GitHub Actions, que fará o build e deploy na Vercel

Write-Host "🚀 Iniciando processo de envio para o GitHub Actions..." -ForegroundColor Cyan

# Verifica se tem arquivos para dar commit
$gitStatus = git status --porcelain
if ([string]::IsNullOrWhiteSpace($gitStatus)) {
    Write-Host "✅ Não há alterações novas para enviar." -ForegroundColor Green
    exit 0
}

# Adiciona todas as mudanças
git add .

# Pede mensagem de commit ou usa padrão
$commitMessage = Read-Host "💬 Digite a mensagem de commit (deixe em branco para 'Atualização de código')"

if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "Atualização de código"
}

# Faz o commit
git commit -m "$commitMessage"

# Envia para o repositório no GitHub (disparando o Github Actions)
Write-Host "📤 Enviando para o GitHub..." -ForegroundColor Yellow
git push origin main

Write-Host "🎉 Enviado com sucesso! O GitHub Actions começará o pnpm build e deploy na Vercel agora." -ForegroundColor Green
