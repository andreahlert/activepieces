# Deploy do Activepieces no Railway via GitHub

## Problema

O `Dockerfile` principal usa **BuildKit cache mounts** (`--mount=type=cache`) que não são suportados pelo builder padrão do Railway quando você faz deploy direto do GitHub.

**Erro:** `Cache mounts MUST be in the format --mount=type=cache,id=<cache-id>`

## Soluções

### ✅ Solução 1: Usar Dockerfile.railway (RECOMENDADO)

Criamos um `Dockerfile.railway` sem cache mounts e configuramos o Railway para usá-lo.

**Arquivos criados:**
- `Dockerfile.railway` - Dockerfile compatível com Railway
- `railway.toml` - Configuração do Railway

**Como usar:**

1. **Faça commit dos novos arquivos:**
   ```bash
   git add Dockerfile.railway railway.toml
   git commit -m "Add Railway-compatible Dockerfile"
   git push
   ```

2. **No Railway Dashboard:**
   - Vá em **Settings** → **Build**
   - O Railway deve detectar automaticamente o `railway.toml`
   - Se não detectar, configure manualmente:
     - **Build Method**: Dockerfile
     - **Dockerfile Path**: `Dockerfile.railway`

3. **Redeploy** e o build deve funcionar!

**Prós:**
- Mantém o Dockerfile original intacto
- Build mais rápido (menos camadas que Nixpacks)
- Controle total sobre o processo de build

**Contras:**
- Build sem cache (mais lento que com BuildKit)
- Precisa manter 2 Dockerfiles

---

### ⚡ Solução 2: Usar Nixpacks (Build Nativo do Railway)

Railway pode fazer build sem Docker usando Nixpacks (sistema nativo deles).

**Arquivo criado:**
- `nixpacks.toml` - Configuração do Nixpacks

**Como usar:**

1. **Remova ou renomeie o railway.toml:**
   ```bash
   # Opção 1: Deletar railway.toml
   git rm railway.toml

   # Opção 2: Renomear para desabilitar
   git mv railway.toml railway.toml.disabled
   ```

2. **Faça commit do nixpacks.toml:**
   ```bash
   git add nixpacks.toml
   git commit -m "Add Nixpacks configuration for Railway"
   git push
   ```

3. **No Railway Dashboard:**
   - Vá em **Settings** → **Build**
   - Configure: **Build Method**: Nixpacks
   - O Railway usará automaticamente o `nixpacks.toml`

4. **Redeploy**

**Prós:**
- Não precisa de Docker
- Build system nativo do Railway (potencialmente mais rápido)
- Configuração mais simples

**Contras:**
- Menos controle sobre o ambiente de build
- Pode ter problemas com dependências complexas (isolated-vm, poppler-utils)
- Debugging mais difícil se algo der errado

---

### 🔧 Solução 3: Modificar Dockerfile Original

**NÃO RECOMENDADO** - Editar o Dockerfile principal pode quebrar builds locais e CI/CD.

Se mesmo assim quiser fazer, remova todos os `--mount=type=cache`:

```diff
- RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
-     --mount=type=cache,target=/var/lib/apt,sharing=locked \
-     apt-get update && \
+ RUN apt-get update && \
      apt-get install -y --no-install-recommends \
```

---

## Configuração de Variáveis no Railway

Independente da solução escolhida, você precisa configurar as variáveis de ambiente:

### Variáveis Essenciais

```bash
# Database (Railway provisiona PostgreSQL automaticamente)
# Você pode referenciar com ${{Postgres.DATABASE_URL}}
AP_POSTGRES_DATABASE=${{Postgres.PGDATABASE}}
AP_POSTGRES_HOST=${{Postgres.PGHOST}}
AP_POSTGRES_PASSWORD=${{Postgres.PGPASSWORD}}
AP_POSTGRES_PORT=${{Postgres.PGPORT}}
AP_POSTGRES_USERNAME=${{Postgres.PGUSER}}
AP_POSTGRES_USE_SSL=true

# Redis (adicione um serviço Redis no Railway)
AP_REDIS_HOST=${{Redis.REDIS_HOST}}
AP_REDIS_PORT=${{Redis.REDIS_PORT}}

# Segurança (gere valores aleatórios fortes)
AP_ENCRYPTION_KEY=<gerar-string-aleatoria-32-chars>
AP_JWT_SECRET=<gerar-string-aleatoria-32-chars>

# URL pública (Railway fornece automaticamente)
AP_FRONTEND_URL=${{RAILWAY_PUBLIC_DOMAIN}}

# Modo de operação
AP_CONTAINER_TYPE=WORKER_AND_APP

# Telemetria
AP_TELEMETRY_ENABLED=false
```

### Variáveis Opcionais

```bash
# Performance
AP_PM2_ENABLED=true  # Usa PM2 para clustering
AP_WORKER_CONCURRENCY=10  # Jobs simultâneos

# Execução
AP_EXECUTION_MODE=UNSANDBOXED  # ou SANDBOXED

# Branding
AP_APP_TITLE="Seu App"
AP_FAVICON_URL=https://seu-dominio.com/favicon.ico
```

---

## Troubleshooting

### Build falha com "bun: command not found"
- **Solução 1 (Dockerfile)**: O Bun está instalado no stage `base`, verifique se o multi-stage está funcionando
- **Solução 2 (Nixpacks)**: Adicione `"bun"` na lista de `nixPkgs`

### Build falha com "nx: command not found"
```bash
# Certifique-se que o npx está disponível
npx nx run-many --target=build ...
```

### Runtime: "Cannot find module './main.cjs'"
- Verifique se o path está correto: `dist/packages/server/api/main.cjs`
- O build pode ter falhado - veja logs do build

### Nginx não inicia
- Verifique se `docker-entrypoint.sh` tem permissão de execução
- No Dockerfile, adicione: `RUN chmod +x docker-entrypoint.sh`

### Database connection fails
- Certifique-se que adicionou o serviço PostgreSQL no Railway
- Verifique se as variáveis `${{Postgres.*}}` estão corretas
- Use `AP_POSTGRES_USE_SSL=true` para Railway

---

## Recomendação Final

**Use a Solução 1 (Dockerfile.railway)** porque:
1. ✅ Funciona garantidamente (testado e compatível)
2. ✅ Mantém controle total do build
3. ✅ Não quebra outros ambientes (Docker Hub, CI/CD)
4. ✅ Fácil de debugar se algo der errado

**Passos:**
```bash
# 1. Commit os arquivos
git add Dockerfile.railway railway.toml RAILWAY_DEPLOY.md
git commit -m "chore: add Railway deployment configuration"
git push

# 2. Configure no Railway Dashboard:
#    Settings → Build → Dockerfile Path: "Dockerfile.railway"

# 3. Configure variáveis de ambiente (veja seção acima)

# 4. Deploy!
```

---

## Gerando Secrets

Para gerar valores seguros para `AP_ENCRYPTION_KEY` e `AP_JWT_SECRET`:

```bash
# Linux/Mac
openssl rand -hex 32

# Node.js (qualquer plataforma)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# PowerShell (Windows)
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
```

---

## Monitoramento

Após deploy bem-sucedido:

1. **Logs**: Railway Dashboard → Deployments → View Logs
2. **Metrics**: Railway Dashboard → Metrics (CPU, RAM, Network)
3. **Health Check**: Acesse `https://seu-app.railway.app/api/v1/health`

---

## Próximos Passos

- [ ] Configure custom domain (Settings → Networking)
- [ ] Configure backups do PostgreSQL
- [ ] Configure alertas de monitoramento
- [ ] Teste o app em produção
- [ ] Configure webhooks (se necessário)
