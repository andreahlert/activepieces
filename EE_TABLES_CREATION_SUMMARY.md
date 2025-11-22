# Enterprise Edition Tables Creation - Summary

## Overview
This document summarizes the SQL script created to set up all Enterprise Edition tables in Railway PostgreSQL.

## Script Location
`C:\dev\activepieces\create_all_ee_tables.sql`

## Tables Created (11 Total)

### 1. **flow_template**
- **Purpose**: Stores flow templates for reuse across platform
- **Key Fields**: name, description, type, platformId, projectId, template (jsonb), tags, pieces
- **Foreign Keys**: platformId → platform, projectId → project
- **Indices**: tags, pieces
- **Based on**: FlowTemplateEntity + migration 1703411318826

### 2. **custom_domain**
- **Purpose**: Custom domain management for platforms
- **Key Fields**: domain, platformId, status
- **Foreign Keys**: platformId → platform
- **Unique Constraint**: domain (unique across all platforms)
- **Based on**: CustomDomainEntity

### 3. **project_role**
- **Purpose**: Defines roles and permissions for project members
- **Key Fields**: name, permissions (array), platformId, type
- **Default Roles**: VIEWER, EDITOR, ADMIN, OPERATOR (pre-populated)
- **Permissions**: READ_APP_CONNECTION, WRITE_FLOW, UPDATE_FLOW_STATUS, etc.
- **Based on**: Migration 1731424289830

### 4. **project_member**
- **Purpose**: Links users to projects with specific roles
- **Key Fields**: projectId, platformId, userId, projectRoleId
- **Foreign Keys**:
  - projectId → project
  - userId → user
  - projectRoleId → project_role
- **Unique Constraint**: (projectId, userId, platformId)
- **Based on**: ProjectMemberEntity + migration 1701647565290

### 5. **signing_key**
- **Purpose**: Stores public keys for JWT/webhook signing
- **Key Fields**: platformId, publicKey, algorithm, displayName
- **Foreign Keys**: platformId → platform (RESTRICT on delete)
- **Based on**: Migration 1698602417745

### 6. **oauth_app**
- **Purpose**: Stores OAuth app configurations per platform
- **Key Fields**: pieceName, platformId, clientId, clientSecret (jsonb)
- **Foreign Keys**: platformId → platform
- **Unique Constraint**: (platformId, pieceName)
- **Based on**: Migration 1699221414907

### 7. **otp**
- **Purpose**: One-time passwords for user verification
- **Key Fields**: type, userId, value, state
- **Foreign Keys**: userId → user
- **Unique Constraint**: (userId, type)
- **Default State**: PENDING
- **Based on**: Migration 1700396157624

### 8. **git_repo**
- **Purpose**: Git repository configuration for project sync
- **Key Fields**: projectId, remoteUrl, branch, branchType, sshPrivateKey, slug, mapping (jsonb)
- **Foreign Keys**: projectId → project
- **Unique Constraint**: projectId (one repo per project)
- **Default Branch Type**: PRODUCTION
- **Based on**: Migration 1704503804056 + subsequent updates

### 9. **audit_event**
- **Purpose**: Audit logging for compliance and security
- **Key Fields**: platformId, projectId, action, userEmail, userId, data (jsonb), ip
- **Foreign Keys**: platformId → platform
- **Indices**:
  - Composite: (platformId, projectId, userId)
  - Individual: platformId, projectId, userId, created
- **Based on**: Migrations 1707614902283 + 1731711188507

### 10. **project_release**
- **Purpose**: Stores project releases/snapshots
- **Key Fields**: projectId, name, description, importedBy, fileId, type
- **Foreign Keys**:
  - projectId → project
  - importedBy → user (SET NULL on delete)
  - fileId → file
- **Based on**: Migration 1734418823028

### 11. **platform_analytics_report**
- **Purpose**: Platform-level analytics and usage reports
- **Key Fields**:
  - Counts: totalFlows, activeFlows, totalUsers, activeUsers, totalProjects, activeProjects
  - Metrics: uniquePiecesUsed, activeFlowsWithAI
  - Data: topPieces (jsonb), tasksUsage (jsonb), topProjects (jsonb)
- **Foreign Keys**: platformId → platform
- **Unique Constraint**: platformId (one report per platform)
- **Based on**: Migration 1753091760355

## Migration Registration

The script registers **16 migrations** in the `migrations` table:
- 1698602417745 - AddSigningKey
- 1698698190965 - AddDisplayNameToSigningKey
- 1699221414907 - AddOAuth2AppEntiity
- 1700396157624 - AddOtpEntity
- 1701084418793 - AddStateToOtp
- 1701647565290 - ModifyProjectMembersAndRemoveUserId
- 1703411318826 - AddPlatformIdToFlowTemplates
- 1704503804056 - AddGitRepoMigrationPostgres
- 1707614902283 - AddAuditEvents
- 1709151540095 - AddSlugToGitRepo
- 1709753080714 - AddMappingStateToGit
- 1711073772867 - AddBranchTypeToGit
- 1731424289830 - CreateProjectRoleTable
- 1731711188507 - AddAuditLogIndicies
- 1734418823028 - CreateProjectReleaseTable
- 1753091760355 - AddPlatformAnalyticsReportEntity

## Features

### Safety Mechanisms
- ✅ Uses `CREATE TABLE IF NOT EXISTS` pattern
- ✅ Wrapped in transaction (BEGIN/COMMIT)
- ✅ Uses `DO $$ ... END $$` blocks for conditional execution
- ✅ `ON CONFLICT DO NOTHING` for migration registration
- ✅ RAISE NOTICE messages for progress tracking

### Verification
- Counts created/verified tables at the end
- Reports success/warning based on table count
- Detailed logging throughout execution

### Idempotency
- Script can be run multiple times safely
- Skips already-created tables
- Won't duplicate migration records
- Won't fail on existing constraints

## How to Execute

### Option 1: Railway PostgreSQL Console
1. Open Railway dashboard
2. Navigate to your PostgreSQL database
3. Open the Query tab
4. Copy and paste the entire script
5. Execute
6. Review the NOTICE messages for results

### Option 2: psql Command Line
```bash
psql "YOUR_DATABASE_URL" -f create_all_ee_tables.sql
```

### Option 3: pgAdmin or DBeaver
1. Open your PostgreSQL tool
2. Connect to Railway database
3. Open SQL editor
4. Paste script
5. Execute

## Post-Execution Verification

After running the script, verify tables exist:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_name IN (
    'flow_template',
    'custom_domain',
    'project_role',
    'project_member',
    'signing_key',
    'oauth_app',
    'otp',
    'git_repo',
    'audit_event',
    'project_release',
    'platform_analytics_report'
)
ORDER BY table_name;
```

Should return 11 rows.

## Important Notes

### Default Role IDs
The script creates 4 default project roles with **fixed IDs**:
- `aJVBSSJ3YqZ7r1laFjM0a` - VIEWER
- `sjWe85TwaFYxyhn2AgOha` - EDITOR
- `461ueYHzMykyk5dIL8HzQ` - ADMIN
- `3Wl9IAw5aM0HLafHgMYkb` - OPERATOR

These IDs are hardcoded in the migration and **must not be changed**.

### Column Types
- **ID columns**: `character varying(21)` (Activepieces uses NanoID)
- **Timestamps**: `TIMESTAMP WITH TIME ZONE` (PostgreSQL specific)
- **JSON data**: `jsonb` (binary JSON for better performance)
- **Arrays**: `character varying array` (PostgreSQL native arrays)

### Cascade Behavior
Most foreign keys use `ON DELETE CASCADE`:
- Deleting a platform removes all related records
- Deleting a project removes all members, releases, etc.
- Deleting a user removes their memberships

**Exceptions**:
- `signing_key.platformId`: Uses RESTRICT (can't delete platform with keys)
- `project_release.importedBy`: Uses SET NULL (preserves release even if user deleted)

## Troubleshooting

### If script fails partway through
The transaction will rollback - no partial state. Fix the error and re-run.

### If tables already exist
Script will skip creation and just register migrations.

### If you need to start fresh
```sql
-- WARNING: This deletes all EE tables!
DROP TABLE IF EXISTS
    platform_analytics_report,
    project_release,
    audit_event,
    git_repo,
    otp,
    oauth_app,
    signing_key,
    project_member,
    project_role,
    custom_domain,
    flow_template
CASCADE;

DELETE FROM migrations WHERE timestamp IN (
    1698602417745, 1698698190965, 1699221414907, 1700396157624,
    1701084418793, 1701647565290, 1703411318826, 1704503804056,
    1707614902283, 1709151540095, 1709753080714, 1711073772867,
    1731424289830, 1731711188507, 1734418823028, 1753091760355
);
```

Then re-run the creation script.

## Related Files

- **Entity Definitions**: `packages/server/api/src/app/ee/*/`
- **Migrations Source**: `packages/server/api/src/app/database/migration/postgres/`
- **Database Common**: `packages/server/api/src/app/database/database-common.ts`

## Next Steps

After running this script:
1. ✅ Restart your Activepieces backend
2. ✅ Verify EE features are accessible
3. ✅ Test creating a project member
4. ✅ Test audit logging (if enabled on platform)
5. ✅ Check that existing data is intact

## Support

If you encounter issues:
1. Check Railway logs for any connection errors
2. Verify all base tables exist (platform, project, user, file)
3. Ensure DATABASE_URL has proper SSL mode
4. Review the NOTICE messages from the script execution
