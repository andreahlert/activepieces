# Como Habilitar API Keys no Activepieces

## 🔍 Problema Identificado

As API Keys estão **bloqueadas por padrão** na versão Community Edition (Open Source). Isso é controlado pelo **Platform Plan** que define quais features estão habilitadas.

**Arquivo:** `packages/ee/shared/src/lib/billing/index.ts:95-121`

```typescript
export const OPEN_SOURCE_PLAN: PlatformPlanWithOnlyLimits = {
    // ... outras features ...
    apiKeysEnabled: false,  // ❌ BLOQUEADO
    // ... outras features ...
}
```

## 🎯 Soluções

Você tem **3 opções** para habilitar API Keys:

---

## ✅ Solução 1: Modificar o OPEN_SOURCE_PLAN (Mais Simples)

### Arquivo: `packages/ee/shared/src/lib/billing/index.ts`

**Localize a linha 116:**
```typescript
apiKeysEnabled: false,
```

**Mude para:**
```typescript
apiKeysEnabled: true,
```

### Rebuild e redeploy:

```bash
# Local (desenvolvimento)
npm run dev

# Railway (produção)
git add packages/ee/shared/src/lib/billing/index.ts
git commit -m "feat: enable API Keys for open source plan"
git push
```

**Prós:**
- ✅ Simples e direto
- ✅ Funciona imediatamente
- ✅ Não precisa mexer no banco de dados

**Contras:**
- ❌ Ativa para TODAS as plataformas
- ❌ Perde a mudança em updates do Activepieces (precisa reaplicar)

---

## ⚙️ Solução 2: Atualizar Platform Plan no Banco de Dados

Se você já tem plataformas criadas, precisa atualizar o `platform_plan` no banco.

### Passo 1: Conectar ao PostgreSQL

**No Railway Dashboard:**
1. Vá no serviço **PostgreSQL**
2. Clique em **Variables** → copie a `DATABASE_URL`
3. Use o Railway CLI ou ferramenta de DB (DBeaver, pgAdmin, psql)

**Via psql (local ou Railway CLI):**
```bash
# Conectar ao banco
psql "postgresql://postgres:senha@host:5432/railway?sslmode=require"
```

### Passo 2: Verificar Platform Plans Existentes

```sql
-- Ver todas as plataformas e seus plans
SELECT
    id,
    "platformId",
    "apiKeysEnabled",
    "ssoEnabled",
    "customDomainsEnabled"
FROM platform_plan;
```

### Passo 3: Habilitar API Keys

```sql
-- Habilitar para TODAS as plataformas
UPDATE platform_plan
SET "apiKeysEnabled" = true;

-- OU habilitar para uma plataforma específica
UPDATE platform_plan
SET "apiKeysEnabled" = true
WHERE "platformId" = 'SEU_PLATFORM_ID';
```

### Passo 4: Verificar a mudança

```sql
SELECT "platformId", "apiKeysEnabled"
FROM platform_plan;
```

**Prós:**
- ✅ Controle granular (por plataforma)
- ✅ Não precisa rebuild
- ✅ Mudança imediata

**Contras:**
- ❌ Precisa acesso ao banco
- ❌ Novas plataformas criadas ainda virão com `false` (precisa da Solução 1 também)

---

## 🚀 Solução 3: Usar Enterprise Edition

Se você quer todas as features desbloqueadas sem hacks:

### Opção A: Configurar EDITION=ee

**No Railway, adicione a variável:**
```bash
AP_EDITION=ee
```

**⚠️ ATENÇÃO:** Isso não "ativa" a Enterprise Edition legalmente. Você ainda precisa de uma **License Key** válida. Sem ela, algumas features podem não funcionar corretamente.

### Opção B: Comprar License Key Oficial

1. Acesse: https://www.activepieces.com/pricing
2. Escolha o plano Enterprise
3. Receberá uma `LICENSE_KEY`
4. Configure no Railway:

```bash
AP_EDITION=ee
AP_LICENSE_KEY=sua-license-key-aqui
```

**Prós:**
- ✅ Suporte oficial
- ✅ Todas as features Enterprise
- ✅ Updates sem perder features
- ✅ Legal e ético

**Contras:**
- ❌ Custa dinheiro

---

## 🧪 Como Testar se Funcionou

### 1. Via UI (Interface Web)

1. Faça login no Activepieces
2. Vá em **Settings** → **API Keys** (ou **Platform** → **API Keys**)
3. Se a página existir e permitir criar keys, funcionou! ✅
4. Clique em **Create API Key**
5. Dê um nome (ex: "Production API")
6. Copie a key gerada (formato: `sk-xxxxxxxxxxxxx`)

### 2. Via API (Testar Criação)

```bash
# 1. Login para obter token JWT
curl -X POST https://seu-app.railway.app/api/v1/authentication/sign-in \
  -H "Content-Type: application/json" \
  -d '{
    "email": "seu-email@example.com",
    "password": "sua-senha"
  }'

# Copie o "token" da resposta

# 2. Criar API Key
curl -X POST https://seu-app.railway.app/api/v1/api-keys \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_JWT" \
  -d '{
    "displayName": "Test API Key"
  }'

# Se retornar 201 Created com a API Key, funcionou! ✅
```

### 3. Via API (Listar Keys Existentes)

```bash
curl -X GET https://seu-app.railway.app/api/v1/api-keys \
  -H "Authorization: Bearer SEU_TOKEN_JWT"
```

---

## 📋 Verificação de Permissões

O código verifica permissões em **2 níveis**:

### 1. Platform Plan Check (`api-key-module.ts:15`)

```typescript
app.addHook('preHandler', platformMustHaveFeatureEnabled(
    (platform) => platform.plan.apiKeysEnabled
))
```

Se `apiKeysEnabled = false`, retorna:
```json
{
  "statusCode": 403,
  "error": "Forbidden",
  "message": "Feature not enabled for this platform"
}
```

### 2. Owner Check (`api-key-module.ts:16`)

```typescript
app.addHook('preHandler', platformMustBeOwnedByCurrentUser)
```

Apenas o **owner da plataforma** pode gerenciar API Keys.

---

## 🎯 Recomendação

### Para Desenvolvimento/Testes:
**Use Solução 1** (modificar OPEN_SOURCE_PLAN)

```bash
# 1. Editar o arquivo
# packages/ee/shared/src/lib/billing/index.ts:116
apiKeysEnabled: true,

# 2. Commit e push
git add packages/ee/shared/src/lib/billing/index.ts
git commit -m "feat: enable API Keys for development"
git push
```

### Para Produção:
**Use Solução 1 + Solução 2**

1. Primeiro, modifique o código (Solução 1) para novas plataformas
2. Depois, atualize plataformas existentes no banco (Solução 2)

```sql
-- Depois de fazer deploy com Solução 1
UPDATE platform_plan SET "apiKeysEnabled" = true;
```

### Para Uso Comercial:
**Use Solução 3** (compre uma licença Enterprise)

É a forma correta e legal de usar todas as features.

---

## 🔐 Usando a API Key Gerada

Depois de criar a API Key, use-a para autenticar requisições:

```bash
# Exemplo: Listar flows
curl -X GET https://seu-app.railway.app/api/v1/flows \
  -H "Authorization: Bearer sk-sua-api-key-aqui"

# Exemplo: Executar flow
curl -X POST https://seu-app.railway.app/api/v1/flows/FLOW_ID/execute \
  -H "Authorization: Bearer sk-sua-api-key-aqui" \
  -H "Content-Type: application/json" \
  -d '{
    "input": {
      "key": "value"
    }
  }'
```

---

## 🛡️ Outras Features Bloqueadas no OPEN_SOURCE_PLAN

Se você quiser desbloquear outras features, aqui está a lista completa:

```typescript
// packages/ee/shared/src/lib/billing/index.ts:95-121
export const OPEN_SOURCE_PLAN = {
    embeddingEnabled: false,           // Embed flows em sites externos
    globalConnectionsEnabled: false,   // Conexões compartilhadas
    customRolesEnabled: false,         // Roles customizadas
    environmentsEnabled: false,        // Ambientes (dev/staging/prod)
    analyticsEnabled: false,           // Analytics avançadas
    auditLogEnabled: false,            // Logs de auditoria
    managePiecesEnabled: false,        // Gerenciar pieces customizadas
    manageTemplatesEnabled: false,     // Gerenciar templates
    customAppearanceEnabled: false,    // Customizar aparência
    manageProjectsEnabled: false,      // Múltiplos projetos
    projectRolesEnabled: false,        // Roles por projeto
    customDomainsEnabled: false,       // Domínios customizados
    apiKeysEnabled: false,             // ❌ API Keys (seu problema)
    ssoEnabled: false,                 // Single Sign-On (SAML, OAuth)

    // Features HABILITADAS no open source:
    mcpsEnabled: true,                 // ✅ Model Context Protocol
    tablesEnabled: true,               // ✅ Tables (database interno)
    todosEnabled: true,                // ✅ TODOs
    agentsEnabled: true,               // ✅ AI Agents
}
```

Para habilitar qualquer uma, mude `false` → `true` no mesmo arquivo.

---

## 📝 Checklist de Implementação

- [ ] Decidir qual solução usar (1, 2 ou 3)
- [ ] Modificar código (Solução 1) OU atualizar banco (Solução 2) OU comprar licença (Solução 3)
- [ ] Fazer commit e push (se Solução 1)
- [ ] Aguardar deploy no Railway
- [ ] Verificar via UI se página de API Keys aparece
- [ ] Criar primeira API Key
- [ ] Testar autenticação com a key
- [ ] Documentar a API Key em lugar seguro (não commitar!)

---

## 🚨 Avisos Importantes

1. **Segurança**: API Keys dão acesso total à plataforma. Guarde-as com segurança!
2. **Licenciamento**: Modificar features do Enterprise Edition pode violar a licença. Use por sua conta e risco ou compre uma licença.
3. **Updates**: Quando atualizar o Activepieces, suas mudanças no código podem ser perdidas. Documente bem!
4. **Backup**: Antes de modificar o banco de dados, faça backup!

---

## 📚 Referências

- **Código API Keys**: `packages/server/api/src/app/ee/api-keys/`
- **Plans**: `packages/ee/shared/src/lib/billing/index.ts`
- **Platform Entity**: `packages/server/api/src/app/platform/platform.entity.ts`
- **Docs Oficiais**: https://www.activepieces.com/docs

---

## 💡 Próximos Passos

Depois de habilitar API Keys, você pode:

1. **Criar webhooks** que usam API Keys para autenticação
2. **Integrar com sistemas externos** usando a API
3. **Automatizar criação de flows** via API
4. **Monitorar execuções** programaticamente
5. **Construir dashboards customizados** usando os dados da API

Quer ajuda implementando alguma dessas soluções?
