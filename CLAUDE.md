# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Activepieces is an open-source AI automation platform (alternative to Zapier) built with TypeScript. The system is designed around a plugin architecture called "pieces" (280+ integrations) that are also available as MCP (Model Context Protocol) servers for use with LLMs.

## Monorepo Structure (Nx + Bun)

This is an **Nx 22.0.1** monorepo using **Bun** as the package manager. All packages live in `packages/`:

```
packages/
├── server/api/           # Fastify API server (port 3000)
├── server/worker/        # BullMQ background worker
├── server/shared/        # Backend utilities
├── engine/               # Isolated flow execution engine
├── react-ui/             # React 18 + Vite frontend
├── shared/               # Shared types used across all packages
├── pieces/community/     # 280+ integration plugins
├── pieces/custom/        # Custom pieces
├── cli/                  # CLI for piece development
├── ee/                   # Enterprise Edition features
└── tests-e2e/           # Playwright E2E tests
```

## Development Commands

### Running the Application

```bash
# Install dependencies and run everything (Frontend + API + Engine)
npm run start

# Development mode (all services)
npm run dev

# Backend only (API + Engine)
npm run dev:backend

# Frontend only (with API + Engine)
npm run dev:frontend

# Individual services
npm run serve:frontend   # React UI (Vite)
npm run serve:backend    # API server (Fastify)
npm run serve:engine     # Engine process
```

### Testing

```bash
# Run all tests
npx nx run-many --target=test

# Run tests for specific package
npx nx test <package-name>

# E2E tests
npm run test:e2e

# Run linting
npx nx run-many --target=lint

# Fix linting issues
npx nx run-many --target=lint --fix
```

### Building

```bash
# Build all packages
npx nx run-many --target=build

# Build specific package
npx nx build <package-name>
```

### Piece Development (CLI Commands)

```bash
# Create new piece
npm run create-piece

# Create new action for a piece
npm run create-action

# Create new trigger for a piece
npm run create-trigger

# Build a piece
npm run build-piece

# Sync pieces from cloud registry
npm run sync-pieces

# Publish piece to npm
npm run publish-piece

# Publish piece to API
npm run publish-piece-to-api
```

## Core Architecture

### Backend: Dual-Mode Server

The backend has two operational modes:

1. **App Mode**: Fastify API server handling HTTP/WebSocket requests
2. **Worker Mode**: BullMQ worker processing background jobs

Both modes run from the same codebase (`packages/server/api`).

**Key Technologies:**
- **Framework**: Fastify 5.4.0
- **ORM**: TypeORM 0.3.18 (PostgreSQL/SQLite)
- **Queue**: BullMQ 5.61.0 (Redis-backed)
- **Real-time**: Socket.IO 4.8.1
- **Validation**: Zod 3.25.76 + @sinclair/typebox 0.34.11

### Engine: Isolated Flow Execution

The engine (`packages/engine`) runs flow operations in isolated Node.js processes spawned by the API/worker. It handles:

- Flow execution (step-by-step)
- Piece loading and execution
- Code execution (with npm package support)
- Variable interpolation
- Loop and branch logic

**Communication**: Uses worker sockets to communicate with parent process.

### Frontend: React + Vite

**Stack:**
- React 18.3.1 + TypeScript
- Vite 6.4.1 (build tool)
- Tailwind CSS 3.4.3
- Radix UI (component primitives)
- TanStack Query 5.51.1 (data fetching)
- Zustand 4.5.4 (state management)
- React Router DOM 6.11.2

**Feature-based organization**: Code is organized in `packages/react-ui/src/features/` by domain (flows, pieces, agents, etc.).

### Pieces System: Plugin Architecture

**Pieces** are TypeScript-based plugins providing integrations. They're npm packages that export:

- `createPiece()`: Main piece definition
- **Actions**: Operations the piece can perform
- **Triggers**: Events that start flows
- **Auth**: Authentication configuration (OAuth, API keys, custom)
- **Properties**: Dynamic configuration fields

**Location**: `packages/pieces/community/<piece-name>/`

**Framework**: `@activepieces/pieces-framework` provides the SDK.

**Key Concepts:**
- Pieces are hot-reloadable during local development
- All pieces are available as MCP servers for LLM use
- Piece metadata is synced from `https://cloud.activepieces.com/api/v1/pieces`
- Over 280+ community-contributed pieces available

## Database & Migrations

**ORM**: TypeORM with automatic migrations on startup.

**Supported Databases:**
- PostgreSQL (production)
- SQLite (development)

**Migration Files**: Located in `packages/server/api/src/app/database/migration/`
- Separate variants for PostgreSQL and SQLite (when necessary)
- Timestamp-based naming (e.g., `1234567890-AddMcpEntities.ts`)

**Key Entities:**
- `Flow`, `FlowVersion`, `FlowRun`, `StepRun`
- `User`, `Project`, `Platform`
- `PieceMetadata`, `AppConnection`
- `Table`, `Field`, `Record`, `Cell`
- `Agent`, `AgentRun`

**Important**: Always check for existing migrations before creating new ones. Use distributed locks to prevent migration race conditions in multi-instance deployments.

## TypeScript Path Aliases

The monorepo uses extensive path aliases (see `tsconfig.base.json`). Key imports:

```typescript
import { ... } from '@activepieces/shared'              // Shared types
import { ... } from '@activepieces/server-shared'       // Server utilities
import { ... } from '@activepieces/pieces-framework'    // Piece SDK
import { ... } from '@activepieces/engine'              // Engine types
import { ... } from '@activepieces/ee-shared'           // EE features
import { ... } from 'server-worker'                     // Worker types
```

## Code Quality & Standards

### Linting

- ESLint with TypeScript plugin
- **Forbidden imports**: No lodash imports (use native JS instead)
- **Module boundaries**: Enforced via `@nx/enforce-module-boundaries`
- Run `npx nx run-many --target=lint --fix` after code changes

### Testing Strategy

- **Unit/Integration**: Jest 30.0.5
- **E2E**: Playwright 1.54.1
- Tests are colocated with packages (`<package>/test/` or `*.spec.ts`)
- Mock helpers available in `packages/server/api/test/helpers/`

## Important Development Notes

### Process Management on Windows

**CRITICAL**: Never run `taskkill //F //IM node.exe` - this will kill Claude Code!

**Correct approach:**
```bash
# Find process on specific port
netstat -ano | findstr :<PORT>

# Kill specific PID
taskkill //F //PID <pid>

# Or use alternative port
PORT=<other-port> npm run dev
```

### Hot Reloading & Piece Development

- Pieces support hot reloading during local development
- Use the CLI commands to scaffold new pieces/actions/triggers
- Piece changes are reflected immediately without server restart

### Real-time Updates

- WebSocket communication via Socket.IO
- Redis adapter for horizontal scaling
- Flow execution updates sent in real-time to UI
- Progress, logs, and step outputs streamed live

### Queue System

- BullMQ handles all background jobs
- Bull Board UI available for queue monitoring
- System jobs (like piece sync) run on schedule
- Job migrations handle queue schema updates

### Enterprise Edition

EE features are in `packages/ee/`:
- SAML/SSO authentication
- RBAC and project roles
- Audit logs
- Custom domains
- Git sync
- Platform analytics
- Advanced billing

## Common Development Workflows

### Creating a New Piece

1. Run `npm run create-piece`
2. Follow CLI prompts to scaffold piece structure
3. Implement actions/triggers in `packages/pieces/community/<piece-name>/src/lib/`
4. Define auth in `src/lib/auth.ts`
5. Export piece in `src/index.ts`
6. Test locally with hot reload
7. Build with `npm run build-piece`
8. Publish to npm with `npm run publish-piece`

### Modifying Backend APIs

1. Make changes in `packages/server/api/src/app/<module>/`
2. If schema changes, update TypeORM entities
3. Create migration if needed: add file to `database/migration/`
4. Restart backend: `npm run serve:backend`
5. Test with API client or frontend

### Frontend Development

1. Work in `packages/react-ui/src/features/<feature>/`
2. Use TanStack Query for data fetching
3. Use Zustand for local UI state
4. Follow Radix UI patterns for components
5. Hot reload active via Vite

### Running Tests

1. Write tests next to implementation or in `test/` folder
2. Run `npx nx test <package>` for specific package
3. Use mocks from `packages/server/api/test/helpers/mocks/`
4. E2E tests: `npm run test:e2e`

## Debugging Tips

### Common Issues

1. **Port already in use**: See process management section above
2. **Module not found after refactor**: Clear cache, restart dev server
3. **TypeScript path errors**: Check `tsconfig.base.json` aliases
4. **Database errors**: Verify migrations ran (`ls packages/server/api/src/app/database/migration/`)
5. **Piece not loading**: Check piece metadata sync, verify export in `index.ts`

### Logging

- Pino logger used throughout backend
- Structured logging with JSON format
- Log levels: trace, debug, info, warn, error, fatal
- OpenTelemetry instrumentation available

### Observability

- OpenTelemetry (OTEL) integration for traces/metrics
- Service names: `activepieces-api` (app), `activepieces-worker` (worker)
- Sentry integration for error tracking
- Bull Board for queue monitoring

## Multi-Tenant Architecture

- **Platform**: Top-level tenant isolation
- **Project**: Workspace within a platform
- **User**: Can belong to multiple projects with different roles
- **Flows**: Scoped to projects
- **Connections**: App credentials scoped to projects

## Key Files to Know

- `nx.json`: Nx workspace configuration
- `tsconfig.base.json`: TypeScript path aliases
- `package.json`: Scripts and dependencies
- `packages/shared/src/index.ts`: All shared types
- `packages/server/api/src/main.ts`: API entry point
- `packages/engine/src/main.ts`: Engine entry point
- `packages/react-ui/src/main.tsx`: Frontend entry point

## Documentation & Resources

- Official docs: https://www.activepieces.com/docs
- Piece development: https://www.activepieces.com/docs/developers/building-pieces/overview
- Deployment: https://www.activepieces.com/docs/install/overview
- Discord: https://discord.gg/yvxF5k5AUb
- Pieces catalog: https://www.activepieces.com/pieces

## Environment Variables

Key environment variables (defined in `AppSystemProp` and `WorkerSystemProp`):

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection for BullMQ
- `AP_EXECUTION_MODE`: `UNSANDBOXED` or `SANDBOXED`
- `AP_PIECES_SOURCE`: `FILE` (dev) or `CLOUD_AND_DB` (prod)
- `AP_TELEMETRY_ENABLED`: OpenTelemetry toggle
- `SENTRY_DSN`: Error tracking endpoint

Refer to `packages/server/shared/src/lib/system/app-system-prop.ts` for full list.
