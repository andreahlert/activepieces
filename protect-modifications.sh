#!/bin/bash
# protect-modifications.sh
# Script para proteger modificações customizadas do Activepieces

echo "🔒 Protegendo modificações customizadas..."
echo ""

# Proteger arquivos com skip-worktree
echo "Aplicando git skip-worktree nos arquivos modificados..."

git update-index --skip-worktree packages/ee/shared/src/lib/billing/index.ts
if [ $? -eq 0 ]; then
    echo "✅ packages/ee/shared/src/lib/billing/index.ts protegido"
else
    echo "❌ Erro ao proteger packages/ee/shared/src/lib/billing/index.ts"
fi

git update-index --skip-worktree packages/server/api/src/app/helper/telemetry.utils.ts
if [ $? -eq 0 ]; then
    echo "✅ packages/server/api/src/app/helper/telemetry.utils.ts protegido"
else
    echo "❌ Erro ao proteger packages/server/api/src/app/helper/telemetry.utils.ts"
fi

echo ""
echo "📋 Arquivos protegidos (não serão sobrescritos em git pull):"
git ls-files -v | grep ^S

echo ""
echo "✅ Proteção concluída!"
echo ""
echo "📝 Próximos passos:"
echo "1. Configure no Railway: AP_TELEMETRY_ENABLED=false"
echo "2. Considere tornar o repo privado no GitHub"
echo "3. Faça commit e push das mudanças"
echo ""
echo "Para reverter a proteção no futuro:"
echo "git update-index --no-skip-worktree packages/ee/shared/src/lib/billing/index.ts"
echo "git update-index --no-skip-worktree packages/server/api/src/app/helper/telemetry.utils.ts"
