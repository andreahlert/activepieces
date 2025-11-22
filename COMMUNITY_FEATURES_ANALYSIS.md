# Análise de Features para COMMUNITY Edition

## Status Atual (após habilitar API Keys)

### ✅ Features Já Funcionando
- **MCPs**: Habilitado por padrão
- **Tables**: Habilitado por padrão
- **Todos**: Habilitado por padrão
- **Agents**: Habilitado por padrão
- **API Keys**: ✅ COMPLETO (módulo + entity + migration)

### 🔧 Features Habilitadas no Plano mas NÃO Funcionais

#### 1. Project Roles & Members (`projectRolesEnabled: true`)
**O que faz:** Controle de acesso baseado em roles (Admin, Editor, Viewer) por projeto

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(projectMemberModule)
await app.register(projectRoleModule)

// database-connection.ts - linha 134
ProjectMemberEntity,
ProjectRoleEntity,
```

**Migrations necessárias:**
- `1714137103728-AddFeatureFlagsToPlatform.ts` (project roles)
- Verificar outras migrations de project-members/

**Rotas que vão funcionar:**
- `GET/POST/DELETE /api/v1/project-members`
- `GET/POST/PUT/DELETE /api/v1/project-roles`

---

#### 2. Analytics (`analyticsEnabled: true`)
**O que faz:** Dashboard de analytics da plataforma (uso de pieces, flows ativos, etc)

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(platformAnalyticsModule)

// database-connection.ts - linha 134
PlatformAnalyticsReportEntity,
```

**Migrations necessárias:**
- Verificar migrations de analytics

**Rotas que vão funcionar:**
- `GET/POST /api/v1/analytics`

---

#### 3. Audit Logs (`auditLogEnabled: true`)
**O que faz:** Log de todas ações na plataforma (quem fez o quê e quando)

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(auditEventModule)

// database-connection.ts - linha 134
AuditEventEntity,
```

**Migrations necessárias:**
- Verificar migrations de audit-event

**Rotas que vão funcionar:**
- `GET /api/v1/audit-events`

---

#### 4. Custom Domains (`customDomainsEnabled: true`)
**O que faz:** Permite configurar domínios customizados para a plataforma

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(customDomainModule)

// database-connection.ts - linha 134
CustomDomainEntity,
```

**Migrations necessárias:**
- Verificar migrations de custom-domain

**Rotas que vão funcionar:**
- `GET/POST/PUT/DELETE /api/v1/custom-domains`

---

#### 5. SSO/SAML (`ssoEnabled: true`)
**O que faz:** Single Sign-On via SAML (Google Workspace, Azure AD, etc)

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(authnSsoSamlModule)
await app.register(federatedAuthModule)
await app.register(managedAuthnModule)
await app.register(otpModule)

// database-connection.ts - linha 134
OtpEntity,
```

**Migrations necessárias:**
- Verificar migrations de otp/saml

**Rotas que vão funcionar:**
- `/api/v1/authn/saml/*`
- `/api/v1/authn/federated/*`

---

#### 6. Manage Projects (`manageProjectsEnabled: true`)
**O que faz:** Gerenciamento avançado de múltiplos projetos na plataforma

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(platformProjectModule)

// database-connection.ts - linha 134
// ProjectEntity já está registrado por padrão
```

**Rotas que vão funcionar:**
- `GET/POST/PUT/DELETE /api/v1/admin/platforms/{platformId}/projects`

---

#### 7. Manage Templates (`manageTemplatesEnabled: true`)
**O que faz:** Criar e gerenciar templates de flows customizados

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(platformFlowTemplateModule)

// database-connection.ts - linha 134
FlowTemplateEntity,
```

**Migrations necessárias:**
- Verificar migrations de flow-template

**Rotas que vão funcionar:**
- `GET/POST/PUT/DELETE /api/v1/flow-templates`

---

#### 8. Manage Pieces (`managePiecesEnabled: true`)
**O que faz:** Controle sobre quais pieces estão disponíveis na plataforma

**Para habilitar:**
```typescript
// app.ts - linha 324
await app.register(platformPieceModule)

// database-connection.ts
// Não precisa de entity adicional
```

**Rotas que vão funcionar:**
- `POST /api/v1/pieces/install`
- `GET /api/v1/pieces/managed`

---

#### 9. Custom Appearance (`customAppearanceEnabled: true`)
**O que faz:** Customizar logo, cores, tema da plataforma

**Para habilitar:**
- Já funciona via `platform` table (primaryColor, logoIconUrl, etc)
- Verificar se há middlewares bloqueando edição

---

## 🚨 Features Ainda Desabilitadas

Estas features estão `false` no OPEN_SOURCE_PLAN:

- `embeddingEnabled: false` - Embedding de flows em sites externos
- `globalConnectionsEnabled: false` - Conexões globais compartilhadas
- `customRolesEnabled: false` - Roles customizadas além de Admin/Editor/Viewer
- `environmentsEnabled: false` - Múltiplos ambientes (dev/staging/prod)

**Se quiser habilitar:** Alterar para `true` e seguir mesmo processo (módulo + entity + migration)

---

## 📝 Checklist Completo para Habilitar Feature

Para cada feature que você quer habilitar:

- [ ] 1. Alterar flag no `OPEN_SOURCE_PLAN` (packages/ee/shared/src/lib/billing/index.ts)
- [ ] 2. Registrar módulo(s) em `app.ts` switch case `ApEdition.COMMUNITY`
- [ ] 3. Registrar entity(ies) em `database-connection.ts` case `COMMUNITY`
- [ ] 4. Verificar migrations e atualizar guards para incluir `ApEdition.COMMUNITY`
- [ ] 5. Executar SQL manual se necessário (como fizemos com api_key)
- [ ] 6. Testar no Railway

---

## 🎯 Sugestão de Prioridade

Se você quiser habilitar mais features, sugiro esta ordem:

1. **Audit Logs** - Útil para compliance e debugging
2. **Project Roles** - Controle de acesso é crítico
3. **Analytics** - Visibilidade do uso da plataforma
4. **Manage Templates** - Facilita onboarding de usuários
5. **Custom Domains** - Branding profissional
6. **SSO/SAML** - Para empresas (mais complexo)

---

Gerado com Claude Code
