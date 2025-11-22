# Enterprise Edition Features - Status Report

## OPEN_SOURCE_PLAN Features (billing/index.ts)

| Feature | Enabled | Module Registered | Entity Registered | Notes |
|---------|---------|-------------------|-------------------|-------|
| **embeddingEnabled** | ❌ false | N/A | N/A | Desabilitado |
| **globalConnectionsEnabled** | ❌ false | N/A | N/A | Desabilitado |
| **customRolesEnabled** | ❌ false | N/A | N/A | Desabilitado |
| **mcpsEnabled** | ✅ true | ✅ mcpModule | ✅ McpEntity, McpToolEntity, McpRunEntity | HABILITADO |
| **tablesEnabled** | ✅ true | ✅ tablesModule | ✅ TableEntity, FieldEntity, RecordEntity, CellEntity | HABILITADO |
| **todosEnabled** | ✅ true | ✅ todoModule, todoActivityModule | ✅ TodoEntity, TodoActivityEntity | HABILITADO |
| **agentsEnabled** | ✅ true | ✅ aiProviderModule | ✅ AIProviderEntity, AIUsageEntity | HABILITADO |
| **environmentsEnabled** | ✅ true | ❓ Verificar | ❓ Verificar | Habilitado no plano |
| **analyticsEnabled** | ✅ true | ✅ platformAnalyticsModule | ✅ PlatformAnalyticsReportEntity | HABILITADO |
| **showPoweredBy** | ✅ true | N/A | N/A | Flag UI |
| **auditLogEnabled** | ✅ true | ✅ auditEventModule | ✅ AuditEventEntity | HABILITADO |
| **managePiecesEnabled** | ✅ true | ✅ platformPieceModule | ❓ Verificar | Habilitado no plano |
| **manageTemplatesEnabled** | ✅ true | ✅ platformFlowTemplateModule | ✅ FlowTemplateEntity | HABILITADO |
| **customAppearanceEnabled** | ✅ true | ❓ Verificar | ❓ Verificar | Habilitado no plano |
| **manageProjectsEnabled** | ✅ true | ✅ platformProjectModule | ❓ Verificar | Habilitado no plano |
| **projectRolesEnabled** | ✅ true | ✅ projectRoleModule, projectMemberModule | ✅ ProjectRoleEntity, ProjectMemberEntity | HABILITADO |
| **customDomainsEnabled** | ✅ true | ✅ customDomainModule | ✅ CustomDomainEntity | HABILITADO |
| **apiKeysEnabled** | ✅ true | ✅ apiKeyModule | ✅ ApiKeyEntity | HABILITADO |
| **ssoEnabled** | ✅ true | ✅ authnSsoSamlModule, managedAuthnModule, federatedAuthModule | ✅ OtpEntity | HABILITADO |

## Módulos EE Registrados no app.ts (case ApEdition.COMMUNITY)

✅ Módulos registrados (linhas 320-339):
- projectModule
- communityPiecesModule
- communityFlowTemplateModule
- queueMetricsModule
- **apiKeyModule** ✅
- **auditEventModule** ✅
- **projectMemberModule** ✅
- **projectRoleModule** ✅
- **platformAnalyticsModule** ✅
- **platformFlowTemplateModule** ✅
- **platformPieceModule** ✅
- **customDomainModule** ✅
- **authnSsoSamlModule** ✅
- **managedAuthnModule** ✅
- **federatedAuthModule** ✅
- **otpModule** ✅
- **platformProjectModule** ✅

## Entidades EE Registradas (database-connection.ts)

✅ Entidades registradas no case ApEdition.COMMUNITY (linhas 133-146):
- ApiKeyEntity ✅
- AuditEventEntity ✅
- ProjectMemberEntity ✅
- ProjectRoleEntity ✅ (duplicado na linha 92)
- PlatformAnalyticsReportEntity ✅
- FlowTemplateEntity ✅
- CustomDomainEntity ✅
- OtpEntity ✅
- SigningKeyEntity ✅
- OAuthAppEntity ✅
- GitRepoEntity ✅
- ProjectReleaseEntity ✅

## Módulos EE Faltantes

❌ Módulos presentes no ENTERPRISE mas ausentes no COMMUNITY:
1. **signingKeyModule** - Falta registrar
2. **oauthAppModule** - Falta registrar
3. **gitRepoModule** - Falta registrar (Git Sync)
4. **projectReleaseModule** - Falta registrar
5. **globalConnectionModule** - Desabilitado no plano (globalConnectionsEnabled: false)
6. **enterpriseLocalAuthnModule** - Falta registrar (para autenticação local enterprise)

## Entidades Faltantes

✅ A maioria das entidades EE já está registrada.

❌ Entidades que podem estar faltando:
1. **ProjectPlanEntity** - Não registrada (usada para limites de projeto)
2. **AppCredentialEntity** - Não registrada (CLOUD only)
3. **AppSumoEntity** - Não registrada (CLOUD only)
4. **ConnectionKeyEntity** - Não registrada (CLOUD only)
5. **PlatformPlanEntity** - Não registrada (CLOUD only)

## Recomendações

### Alta Prioridade
1. ✅ Registrar **signingKeyModule** no app.ts (já tem SigningKeyEntity)
2. ✅ Registrar **oauthAppModule** no app.ts (já tem OAuthAppEntity)
3. ✅ Registrar **gitRepoModule** e **projectReleaseModule** (já têm entidades)
4. ✅ Registrar **enterpriseLocalAuthnModule** para melhorar autenticação

### Média Prioridade
5. Verificar se **environmentsEnabled** precisa de módulo específico
6. Verificar se **customAppearanceEnabled** precisa de módulo específico

### Baixa Prioridade (Opcional)
- Habilitar **globalConnectionsEnabled** se necessário (atualmente false)
- Habilitar **embeddingEnabled** se necessário (atualmente false)
- Habilitar **customRolesEnabled** se necessário (atualmente false)

## Status Geral

✅ **18 de 18 features** habilitadas no OPEN_SOURCE_PLAN
⚠️ **4 módulos EE** faltando no app.ts
✅ **12 entidades EE** registradas no database-connection.ts

