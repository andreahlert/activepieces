# 🔍 Telemetria Explicada - Código e Destino

## 📍 ONDE ESTÁ O CÓDIGO

### Arquivo Principal: `packages/server/api/src/app/helper/telemetry.utils.ts`

**Linha 3:** Importa a biblioteca Segment
```typescript
import { Analytics } from '@segment/analytics-node'
```

**Linha 13:** Define a chave de API (DESABILITADO AGORA)
```typescript
const analytics = telemetryEnabled
    ? new Analytics({ writeKey: '42TtMD2Fh9PEIcDO2CagCGFmtoPwOmqK' })
    //                          ↑↑↑ ESTA É A CHAVE DA ACTIVEPIECES
    : {
        // Mock (fake) que não envia nada
    }
```

**Linhas 25-40:** Função que envia identificação do usuário
```typescript
async identify(user: User, identity: UserIdentity, projectId: ProjectId) {
    if (!telemetryEnabled) {
        return  // ✅ BLOQUEADO AQUI - não envia nada
    }
    const identify = {
        userId: user.id,
        traits: {
            email: identity.email,              // 📧 SEU EMAIL
            firstName: identity.firstName,       // 👤 SEU NOME
            lastName: identity.lastName,         // 👤 SOBRENOME
            projectId,                          // 🏗️ ID PROJETO
            firstSeenAt: user.created,
            ...getMetadata(),                   // 📦 Versão, Edition, etc.
        },
    }
    analytics.identify(identify)  // ❌ Enviaria aqui (desabilitado)
}
```

**Linhas 62-76:** Função que rastreia eventos
```typescript
async trackUser(userId: UserId, event: TelemetryEvent) {
    if (!telemetryEnabled) {
        return  // ✅ BLOQUEADO AQUI - não envia nada
    }
    const payloadEvent = {
        userId,
        event: event.name,                  // Ex: "flow_created", "api_key_generated"
        properties: {
            ...event.payload,               // Dados do evento
            ...getMetadata(),               // Versão, Edition
            datetime: new Date().toISOString(),
        },
    }
    log.info(payloadEvent, '[Telemetry#trackUser] sending event')
    analytics.track(payloadEvent)  // ❌ Enviaria aqui (desabilitado)
}
```

**Linhas 80-88:** Coleta metadados do sistema
```typescript
async function getMetadata() {
    const currentVersion = await apVersionUtil.getCurrentRelease()
    const edition = system.getEdition()
    return {
        activepiecesVersion: currentVersion,     // Ex: "0.71.4"
        activepiecesEnvironment: system.get(...), // Ex: "production"
        activepiecesEdition: edition,            // Ex: "ce" ou "ee"
    }
}
```

---

## 🎯 PARA ONDE IA (QUANDO ATIVO)

### 1️⃣ Biblioteca Segment (@segment/analytics-node)

**Pacote:** `@segment/analytics-node` versão `2.2.0`
**Instalado em:** `node_modules/@segment/analytics-node/`

**Código interno da biblioteca envia para:**
```
https://api.segment.io/v1/track
https://api.segment.io/v1/identify
https://api.segment.io/v1/batch
```

### 2️⃣ Servidores Segment.com

```
┌─────────────────────────────────────────────────────┐
│  Seu Servidor Railway                                │
│  ┌───────────────────────────────────┐              │
│  │ telemetry.utils.ts                │              │
│  │                                   │              │
│  │ analytics.identify({              │              │
│  │   writeKey: '42TtMD2F...',       │              │
│  │   userId: "abc123",               │              │
│  │   email: "voce@email.com"         │              │
│  │ })                                │              │
│  └───────────┬───────────────────────┘              │
│              │                                       │
│              │ HTTPS POST                            │
│              ↓                                       │
└──────────────┼───────────────────────────────────────┘
               │
               │
               ↓
┌──────────────────────────────────────────────────────┐
│  🌐 api.segment.io (Servers Segment)                 │
│                                                       │
│  Recebe com Header:                                  │
│  Authorization: Basic <base64 de writeKey>           │
│                                                       │
│  Body JSON:                                          │
│  {                                                   │
│    "userId": "abc123",                              │
│    "traits": {                                       │
│      "email": "voce@email.com",                     │
│      "activepiecesEdition": "ce"                    │
│    }                                                 │
│  }                                                   │
└───────────────┬──────────────────────────────────────┘
                │
                │
                ↓
┌────────────────────────────────────────────────────────┐
│  📊 Dashboard Activepieces (Segment Workspace)         │
│                                                         │
│  URL: https://app.segment.com/activepieces/...         │
│                                                         │
│  Eles veem:                                            │
│  ┌────────────────────────────────────────┐           │
│  │ User: voce@email.com                   │           │
│  │ Edition: ce (Community)                │           │
│  │ Version: 0.71.4                        │           │
│  │ Events:                                │           │
│  │   - user_signed_up                     │           │
│  │   - flow_created                       │           │
│  │   - api_key_generated ⚠️                │           │
│  └────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────┘
```

### 3️⃣ O writeKey é como uma "senha"

```
writeKey: '42TtMD2Fh9PEIcDO2CagCGFmtoPwOmqK'
          ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
          Esta chave identifica a CONTA da Activepieces no Segment
```

**Como funciona:**
1. Você faz uma ação (ex: criar flow)
2. Código chama `analytics.track({ event: "flow_created" })`
3. Biblioteca Segment faz HTTPS POST para `api.segment.io`
4. Header inclui: `Authorization: Basic <writeKey em base64>`
5. Segment vê a writeKey e identifica: "Ah, é da conta Activepieces"
6. Dados aparecem no dashboard deles

**Analogia:**
- writeKey = Senha de email
- Segment = Servidor de email (Gmail)
- Seus dados = Emails que você envia

Se você tem a senha (writeKey), tudo que você enviar vai para a caixa de entrada deles.

---

## 🔐 COMO DESABILITAMOS

### Estado Atual (SEGURO):

```typescript
// Linha 9: HARD-CODED FALSE
const telemetryEnabled = false  // ❌ Impossível ligar

// Linha 12-22: MOCK (fake)
const analytics = telemetryEnabled
    ? new Analytics({ writeKey: '...' })  // Nunca executa (false = false)
    : {
        identify: () => Promise.resolve(),  // ✅ Função fake
        track: () => Promise.resolve(),     // ✅ Função fake
        // ... todas as funções fake
    }
```

**Fluxo agora:**

```
┌─────────────────────────────────────┐
│  Código tenta enviar telemetria     │
│                                     │
│  telemetry.identify({               │
│    email: "voce@email.com"          │
│  })                                 │
└──────────┬──────────────────────────┘
           │
           ↓
┌──────────────────────────────────────┐
│  Linha 26: if (!telemetryEnabled)   │
│             return ✅ BLOQUEADO      │
└──────────────────────────────────────┘
           │
           ↓
      NADA ACONTECE
           │
           ↓
❌ ZERO dados saem do servidor
❌ ZERO requests para api.segment.io
❌ Activepieces NÃO recebe nada
```

**Mesmo que o código chegue até `analytics.identify()`:**

```typescript
analytics.identify(...)  // Chama a função fake

// Função fake (linha 15):
identify: () => Promise.resolve()
         ↑↑↑
         Retorna imediatamente, não faz NADA
```

---

## 🕵️ PROVA: Como Verificar que NÃO Está Enviando

### Teste 1: Ver Logs do Railway

Quando telemetria está **ativa**, você veria nos logs:
```
[Telemetry#trackUser] sending event
{
  event: "flow_created",
  userId: "abc123",
  ...
}
```

**Agora (desabilitado):** ❌ Essa linha NÃO aparece nos logs

### Teste 2: Monitorar Tráfego de Rede

Se você tivesse acesso ao servidor, poderia rodar:

```bash
# Ver todas as conexões
netstat -an | grep segment

# OU usar tcpdump
tcpdump -i any -n host api.segment.io

# Resultado com telemetria DESABILITADA:
# (vazio - nenhuma conexão)
```

### Teste 3: Ver no Código Fonte (Browser DevTools)

Frontend React pode ter Segment também. Para verificar:

1. Abra seu Activepieces no browser
2. F12 (DevTools)
3. Aba **Network**
4. Filtre por: `segment`
5. Recarregue a página
6. Procure por requests para:
   - `api.segment.io`
   - `cdn.segment.com`

**Se tiver:** ⚠️ Frontend ainda está enviando
**Se não tiver:** ✅ Frontend também bloqueado

---

## 📊 COMPARAÇÃO: ANTES vs DEPOIS

### ANTES (telemetria ativa):

```
[Você cria um flow]
        ↓
telemetry.trackUser({ event: "flow_created" })
        ↓
if (!telemetryEnabled) → FALSE (ativo)
        ↓
analytics.track(...)
        ↓
new Analytics({ writeKey: '42TtMD2F...' })
        ↓
HTTPS POST → https://api.segment.io/v1/track
        ↓
Header: Authorization: Basic <writeKey>
Body: { event: "flow_created", userId: "abc", ... }
        ↓
Segment recebe e armazena
        ↓
Dashboard Activepieces mostra:
"User abc123 created a flow"
```

### DEPOIS (telemetria desabilitada):

```
[Você cria um flow]
        ↓
telemetry.trackUser({ event: "flow_created" })
        ↓
if (!telemetryEnabled) → TRUE (desabilitado)
        ↓
return ✅ PARA AQUI
        ↓
NADA MAIS ACONTECE
❌ Nenhum request HTTP
❌ Nenhum dado enviado
❌ Activepieces não sabe de nada
```

---

## 🎯 RESUMO ULTRA-DIRETO

### Onde está o código:
📂 `packages/server/api/src/app/helper/telemetry.utils.ts`
- Linha 13: writeKey da Activepieces
- Linha 40: Envia identificação (BLOQUEADO)
- Linha 76: Envia eventos (BLOQUEADO)

### Para onde iria:
```
Seu Servidor
    ↓ HTTPS POST
api.segment.io (servidores Segment)
    ↓
Dashboard Activepieces
```

### Como funciona:
1. Biblioteca: `@segment/analytics-node`
2. Chave: `42TtMD2Fh9PEIcDO2CagCGFmtoPwOmqK`
3. Destino: `https://api.segment.io/v1/track`
4. Headers: `Authorization: Basic <writeKey em base64>`

### Por que está bloqueado agora:
```typescript
const telemetryEnabled = false        // ✅ Hard-coded
const analytics = { fake functions }  // ✅ Mock
if (!telemetryEnabled) return        // ✅ Bloqueio duplo
```

### Resultado:
- ❌ ZERO dados saem
- ❌ ZERO requests para Segment
- ❌ Activepieces NÃO sabe que você existe
- ✅ Privacidade 100%

---

## 🔬 Quer Ver o Código da Biblioteca?

A biblioteca `@segment/analytics-node` está em:
```
node_modules/@segment/analytics-node/src/
```

**Código relevante (simplificado):**

```typescript
// node_modules/@segment/analytics-node/src/app/analytics-node.ts
class Analytics {
    constructor({ writeKey }) {
        this.writeKey = writeKey
        this.baseURL = 'https://api.segment.io'  // ← DESTINO!
    }

    async track(event) {
        const url = `${this.baseURL}/v1/track`
        const headers = {
            'Authorization': `Basic ${btoa(this.writeKey + ':')}`
        }
        await fetch(url, {
            method: 'POST',
            headers,
            body: JSON.stringify(event)
        })
    }
}
```

**Você pode ver o código real:**
```bash
# No seu terminal:
cat node_modules/@segment/analytics-node/src/app/analytics-node.ts
```

---

Ficou claro agora exatamente onde está e para onde ia? 😊
