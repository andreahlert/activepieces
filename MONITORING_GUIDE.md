# 🔍 Guia de Monitoramento - Railway Deploy

## 📊 Como Monitorar o Deploy

### 1. Via Railway Dashboard (Recomendado)

**Acesse:** https://railway.app/

1. **Vá para seu projeto Activepieces**
2. **Clique no serviço principal**
3. **Aba "Deployments"**
   - Você verá o deploy `6ec2e32bfe` em progresso
   - Status: `Building` → `Deploying` → `Active`
4. **Aba "Logs"**
   - Logs em tempo real do build e runtime

---

## ⏱️ Timeline Esperada

```
[00:00] Push detectado
[00:01] Build iniciado
[02:00] Instalando dependências (bun install)
[05:00] Compilando projetos (Nx build)
[08:00] Build concluído
[08:30] Deploy iniciado
[09:00] Container subindo
[09:30] ✅ Deploy ativo
```

**Total estimado:** ~9-12 minutos

---

## 🔍 Sinais de Sucesso

### ✅ Build Bem-Sucedido

Procure por estas mensagens nos logs:

```
✓ Built successfully
✓ Deployment successful
✓ Service is running
```

### ✅ Aplicação Iniciada

```
AP_APP_TITLE: Activepieces
AP_FAVICON_URL: https://cdn.activepieces.com/brand/favicon.ico
Starting backend server with Node.js (WORKER mode or default)
Server listening at http://0.0.0.0:3000
```

### ✅ Sem Erros de Telemetria

**NÃO deve aparecer:**
```
❌ Error: writeKey writeKey is missing.
❌ ValidationError('writeKey', 'writeKey is missing.')
```

Se não aparecer esse erro, o fix funcionou! ✅

---

## 🚨 Sinais de Problema

### ❌ Build Falhou

```
Error: Build failed
npm ERR! code 1
Exit code: 1
```

**Solução:** Verificar logs completos para ver qual arquivo/etapa falhou

### ❌ Deploy Crashing

```
Error: Application crashed
Exit code: 137 (out of memory)
Exit code: 1 (error)
```

**Solução:** Verificar logs de runtime, pode ser erro de código

### ❌ Ainda com Erro de Telemetria

Se ainda aparecer:
```
Error: writeKey writeKey is missing.
```

**Significa:** Build pegou código antigo (cache)

**Solução:**
```bash
# No Railway Dashboard:
Settings → Clear Cache → Redeploy
```

---

## 🧪 Como Testar Após Deploy

### Teste 1: Verificar que o App Está Vivo

```bash
# Substitua pela sua URL do Railway
curl https://seu-app.railway.app/api/v1/health

# Resposta esperada:
# Status: 200 OK
```

### Teste 2: Verificar Login

1. Acesse: `https://seu-app.railway.app`
2. Faça login com seu usuário
3. Se carregar a dashboard, está funcionando ✅

### Teste 3: Criar API Key (OBJETIVO PRINCIPAL)

1. **Vá para Settings**
2. **Procure por "API Keys"** no menu
3. **Se a opção aparecer:** ✅ API Keys habilitadas com sucesso!
4. **Clique em "Create API Key"**
5. **Preencha:**
   - Display Name: "Test Key"
6. **Clique em Create**
7. **Copie a key gerada:** `sk-xxxxxxxxxxxxx`

**Se funcionar sem erro:** 🎉 **SUCESSO TOTAL!**

---

## 📋 Checklist de Verificação

Execute após o deploy terminar:

- [ ] Deploy mostra status "Active" no Railway
- [ ] Logs não mostram erro de telemetria
- [ ] App acessível via browser
- [ ] Login funciona
- [ ] Menu "API Keys" aparece em Settings
- [ ] Consegue criar API Key sem erro
- [ ] API Key retornada no formato `sk-xxxxx...`

---

## 🔧 Comandos de Monitoramento (Se tiver Railway CLI)

### Instalar Railway CLI

```bash
# Windows (PowerShell)
iwr https://railway.app/install.ps1 | iex

# Mac/Linux
curl -fsSL https://railway.app/install.sh | sh
```

### Comandos Úteis

```bash
# Login
railway login

# Listar projetos
railway list

# Conectar ao projeto
railway link

# Ver logs em tempo real
railway logs

# Ver status
railway status

# Forçar redeploy
railway up
```

---

## 📊 Monitoramento Avançado

### Ver Logs Completos

No Railway Dashboard:
1. **Deployments** → Clique no deploy ativo
2. **View Logs**
3. Filtre por:
   - `error` - ver apenas erros
   - `telemetry` - verificar telemetria
   - `API` - logs de API
   - `writeKey` - verificar se ainda há erros

### Métricas

1. **Aba "Metrics"**
2. Veja:
   - CPU usage
   - Memory usage
   - Network I/O
   - Restarts (deve ser 0)

**Se CPU/Memory estáveis:** App está rodando bem ✅

---

## 🐛 Troubleshooting Rápido

### Problema: Deploy demora mais de 15 min

**Causa:** Build travado ou Railway com problemas
**Solução:**
```
Settings → Cancel Build → Redeploy
```

### Problema: Deploy fica em "Deploying" infinitamente

**Causa:** App não iniciou (erro no entrypoint)
**Solução:**
1. Ver logs: procurar por erros de sintaxe
2. Verificar que Dockerfile.railway está correto

### Problema: Deploy sucesso mas app não abre

**Causa:** Porta errada ou Nginx não subiu
**Solução:**
1. Ver logs: `docker-entrypoint.sh`
2. Procurar: "nginx" e "Starting backend server"

### Problema: API Keys ainda bloqueadas

**Causa:** Cache do build pegou código antigo
**Solução:**
```bash
# Forçar rebuild completo
Settings → Clear Build Cache → Redeploy
```

---

## 📱 Notificações

Configure no Railway:
1. **Settings** → **Notifications**
2. Habilite:
   - ✅ Deploy succeeded
   - ✅ Deploy failed
   - ✅ Service crashed

Receberá email quando o deploy terminar!

---

## 🎯 Próximo Passo Após Deploy

Quando o deploy estiver ativo:

1. ✅ Teste criar API Key
2. ✅ Copie e guarde a key
3. ✅ Teste usar a key:

```bash
# Listar flows usando API Key
curl https://seu-app.railway.app/api/v1/flows \
  -H "Authorization: Bearer sk-sua-api-key"

# Se retornar JSON com flows: FUNCIONOU!
```

---

## 📞 Me Avise Quando...

- ✅ Deploy terminar (status Active)
- ❌ Houver erro no build/deploy
- ✅ Conseguir criar API Key
- ❌ Qualquer erro inesperado

Estarei aqui para ajudar! 🚀

---

**Última atualização:** 2025-11-20
**Commit sendo deployado:** `6ec2e32bfe`
**Mudança:** Fix telemetry error (mock Analytics)
