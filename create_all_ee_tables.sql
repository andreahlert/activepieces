-- =====================================================
-- Complete EE Tables Creation Script for Railway PostgreSQL
-- =====================================================
-- This script creates all Enterprise Edition tables that are missing
-- from the Railway PostgreSQL database and registers the migrations.
--
-- Tables created:
-- 1. flow_template
-- 2. custom_domain
-- 3. project_member
-- 4. project_role
-- 5. signing_key
-- 6. oauth_app
-- 7. otp
-- 8. git_repo
-- 9. audit_event
-- 10. project_release
-- 11. platform_analytics_report
--
-- Usage: Execute this script in Railway PostgreSQL console
-- =====================================================

BEGIN;

-- =====================================================
-- 1. FLOW_TEMPLATE TABLE
-- =====================================================
-- Based on FlowTemplateEntity and migration 1703411318826
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'flow_template') THEN
        CREATE TABLE "flow_template" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "name" character varying NOT NULL,
            "description" character varying NOT NULL,
            "type" character varying NOT NULL,
            "platformId" character varying NOT NULL,
            "projectId" character varying,
            "template" jsonb NOT NULL,
            "tags" character varying array NOT NULL,
            "pieces" character varying array NOT NULL,
            "blogUrl" character varying,
            "metadata" jsonb,
            CONSTRAINT "PK_flow_template_id" PRIMARY KEY ("id")
        );

        -- Create indices for flow_template
        CREATE INDEX "idx_flow_template_tags" ON "flow_template" ("tags");
        CREATE INDEX "idx_flow_template_pieces" ON "flow_template" ("pieces");

        -- Add foreign keys for flow_template
        ALTER TABLE "flow_template"
            ADD CONSTRAINT "fk_flow_template_platform_id"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        ALTER TABLE "flow_template"
            ADD CONSTRAINT "fk_flow_template_project_id"
            FOREIGN KEY ("projectId") REFERENCES "project"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: flow_template';
    ELSE
        RAISE NOTICE 'Table flow_template already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 2. CUSTOM_DOMAIN TABLE
-- =====================================================
-- Based on CustomDomainEntity
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'custom_domain') THEN
        CREATE TABLE "custom_domain" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "domain" character varying NOT NULL,
            "platformId" character varying(21) NOT NULL,
            "status" character varying NOT NULL,
            CONSTRAINT "PK_custom_domain_id" PRIMARY KEY ("id")
        );

        -- Create unique index on domain
        CREATE UNIQUE INDEX "custom_domain_domain_unique" ON "custom_domain" ("domain");

        -- Add foreign key
        ALTER TABLE "custom_domain"
            ADD CONSTRAINT "fk_custom_domain_platform_id"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: custom_domain';
    ELSE
        RAISE NOTICE 'Table custom_domain already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 3. PROJECT_ROLE TABLE
-- =====================================================
-- Based on migration 1731424289830-CreateProjectRoleTable
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_role') THEN
        CREATE TABLE "project_role" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "name" character varying NOT NULL,
            "permissions" character varying array NOT NULL,
            "platformId" character varying,
            "type" character varying NOT NULL,
            CONSTRAINT "PK_3c677495ab48997b2dc02048289" PRIMARY KEY ("id")
        );

        -- Insert default roles
        INSERT INTO "project_role" ("id", "name", "permissions", "platformId", "type")
        VALUES
            ('aJVBSSJ3YqZ7r1laFjM0a', 'VIEWER', ARRAY['READ_APP_CONNECTION','READ_FLOW','READ_PROJECT_MEMBER','READ_INVITATION','READ_ISSUES']::character varying[], null, 'DEFAULT'),
            ('sjWe85TwaFYxyhn2AgOha', 'EDITOR', ARRAY['READ_APP_CONNECTION','WRITE_APP_CONNECTION','READ_FLOW','WRITE_FLOW','UPDATE_FLOW_STATUS','READ_PROJECT_MEMBER','READ_INVITATION','WRITE_GIT_REPO','READ_GIT_REPO','READ_RUN','WRITE_RUN','READ_ISSUES','WRITE_ISSUES']::character varying[], null, 'DEFAULT'),
            ('461ueYHzMykyk5dIL8HzQ', 'ADMIN', ARRAY['READ_APP_CONNECTION','WRITE_APP_CONNECTION','READ_FLOW','WRITE_FLOW','UPDATE_FLOW_STATUS','READ_PROJECT_MEMBER','WRITE_PROJECT_MEMBER','WRITE_INVITATION','READ_INVITATION','WRITE_GIT_REPO','READ_GIT_REPO','READ_RUN','WRITE_RUN','READ_ISSUES','WRITE_ISSUES','WRITE_ALERT','READ_ALERT','WRITE_PROJECT']::character varying[], null, 'DEFAULT'),
            ('3Wl9IAw5aM0HLafHgMYkb', 'OPERATOR', ARRAY['READ_APP_CONNECTION','WRITE_APP_CONNECTION','READ_FLOW','UPDATE_FLOW_STATUS','READ_PROJECT_MEMBER','READ_INVITATION','READ_GIT_REPO','READ_RUN','WRITE_RUN','READ_ISSUES']::character varying[], null, 'DEFAULT')
        ON CONFLICT ("id") DO NOTHING;

        RAISE NOTICE 'Created table: project_role with default roles';
    ELSE
        RAISE NOTICE 'Table project_role already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 4. PROJECT_MEMBER TABLE
-- =====================================================
-- Based on ProjectMemberEntity and migration 1701647565290
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_member') THEN
        CREATE TABLE "project_member" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "projectId" character varying(21) NOT NULL,
            "platformId" character varying(21) NOT NULL,
            "userId" character varying(21) NOT NULL,
            "projectRoleId" character varying(21) NOT NULL,
            CONSTRAINT "PK_project_member_id" PRIMARY KEY ("id")
        );

        -- Create unique index
        CREATE UNIQUE INDEX "idx_project_member_project_id_user_id_platform_id"
            ON "project_member" ("projectId", "userId", "platformId");

        -- Add foreign keys
        ALTER TABLE "project_member"
            ADD CONSTRAINT "fk_project_member_project_id"
            FOREIGN KEY ("projectId") REFERENCES "project"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        ALTER TABLE "project_member"
            ADD CONSTRAINT "fk_project_member_user_id"
            FOREIGN KEY ("userId") REFERENCES "user"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        ALTER TABLE "project_member"
            ADD CONSTRAINT "fk_project_member_project_role_id"
            FOREIGN KEY ("projectRoleId") REFERENCES "project_role"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: project_member';
    ELSE
        RAISE NOTICE 'Table project_member already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 5. SIGNING_KEY TABLE
-- =====================================================
-- Based on migration 1698602417745-add-signing-key
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'signing_key') THEN
        CREATE TABLE "signing_key" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "platformId" character varying(21) NOT NULL,
            "publicKey" character varying NOT NULL,
            "algorithm" character varying NOT NULL,
            "displayName" character varying,
            CONSTRAINT "PK_934695464c4ffe5280d79ff541a" PRIMARY KEY ("id")
        );

        -- Add foreign key
        ALTER TABLE "signing_key"
            ADD CONSTRAINT "fk_signing_key_platform_id"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE RESTRICT ON UPDATE RESTRICT;

        RAISE NOTICE 'Created table: signing_key';
    ELSE
        RAISE NOTICE 'Table signing_key already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 6. OAUTH_APP TABLE
-- =====================================================
-- Based on migration 1699221414907-AddOAuth2AppEntiity
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'oauth_app') THEN
        CREATE TABLE "oauth_app" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "pieceName" character varying NOT NULL,
            "platformId" character varying(21) NOT NULL,
            "clientId" character varying NOT NULL,
            "clientSecret" jsonb NOT NULL,
            CONSTRAINT "PK_3256b97c0a3ee2d67240805dca4" PRIMARY KEY ("id")
        );

        -- Create unique index
        CREATE UNIQUE INDEX "idx_oauth_app_platformId_pieceName"
            ON "oauth_app" ("platformId", "pieceName");

        -- Add foreign key
        ALTER TABLE "oauth_app"
            ADD CONSTRAINT "fk_oauth_app_platform_id"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: oauth_app';
    ELSE
        RAISE NOTICE 'Table oauth_app already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 7. OTP TABLE
-- =====================================================
-- Based on migration 1700396157624-add-otp-entity
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'otp') THEN
        CREATE TABLE "otp" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "type" character varying NOT NULL,
            "userId" character varying(21) NOT NULL,
            "value" character varying NOT NULL,
            "state" character varying NOT NULL DEFAULT 'PENDING',
            CONSTRAINT "PK_32556d9d7b22031d7d0e1fd6723" PRIMARY KEY ("id")
        );

        -- Create unique index
        CREATE UNIQUE INDEX "idx_otp_user_id_type" ON "otp" ("userId", "type");

        -- Add foreign key
        ALTER TABLE "otp"
            ADD CONSTRAINT "fk_otp_user_id"
            FOREIGN KEY ("userId") REFERENCES "user"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: otp';
    ELSE
        RAISE NOTICE 'Table otp already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 8. GIT_REPO TABLE
-- =====================================================
-- Based on migration 1704503804056-AddGitRepoMigrationPostgres
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'git_repo') THEN
        CREATE TABLE "git_repo" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "projectId" character varying(21) NOT NULL,
            "remoteUrl" character varying NOT NULL,
            "branch" character varying NOT NULL,
            "branchType" character varying NOT NULL DEFAULT 'PRODUCTION',
            "sshPrivateKey" character varying,
            "slug" character varying,
            "mapping" jsonb,
            CONSTRAINT "REL_5b59d96420074128fc1d269b9c" UNIQUE ("projectId"),
            CONSTRAINT "PK_de881ac6eac39e4d9ba7c5ed3e6" PRIMARY KEY ("id")
        );

        -- Create unique index
        CREATE UNIQUE INDEX "idx_git_repo_project_id" ON "git_repo" ("projectId");

        -- Add foreign key
        ALTER TABLE "git_repo"
            ADD CONSTRAINT "fk_git_repo_project_id"
            FOREIGN KEY ("projectId") REFERENCES "project"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: git_repo';
    ELSE
        RAISE NOTICE 'Table git_repo already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 9. AUDIT_EVENT TABLE
-- =====================================================
-- Based on migration 1707614902283-AddAuditEvents
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_event') THEN
        CREATE TABLE "audit_event" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "platformId" character varying NOT NULL,
            "projectId" character varying,
            "action" character varying NOT NULL,
            "userEmail" character varying NOT NULL,
            "projectDisplayName" character varying,
            "data" jsonb NOT NULL,
            "ip" character varying,
            "userId" character varying NOT NULL,
            CONSTRAINT "PK_481efbe8b0a403efe3f47a6528f" PRIMARY KEY ("id")
        );

        -- Create composite index
        CREATE INDEX "audit_event_platform_id_project_id_user_id_idx"
            ON "audit_event" ("platformId", "projectId", "userId");

        -- Create additional indices from migration 1731711188507
        CREATE INDEX "idx_audit_event_platform_id" ON "audit_event" ("platformId");
        CREATE INDEX "idx_audit_event_project_id" ON "audit_event" ("projectId");
        CREATE INDEX "idx_audit_event_user_id" ON "audit_event" ("userId");
        CREATE INDEX "idx_audit_event_created" ON "audit_event" ("created");

        -- Add foreign key
        ALTER TABLE "audit_event"
            ADD CONSTRAINT "FK_8188cdbf5c16c58d431efddd451"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: audit_event';
    ELSE
        RAISE NOTICE 'Table audit_event already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 10. PROJECT_RELEASE TABLE
-- =====================================================
-- Based on migration 1734418823028-CreateProjectReleaseTable
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'project_release') THEN
        CREATE TABLE "project_release" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "projectId" character varying NOT NULL,
            "name" character varying NOT NULL,
            "description" character varying,
            "importedBy" character varying(21),
            "fileId" character varying NOT NULL,
            "type" character varying NOT NULL,
            CONSTRAINT "PK_11aa4566a8a7a623e5c3f9809fe" PRIMARY KEY ("id")
        );

        -- Create index
        CREATE INDEX "idx_project_release_project_id" ON "project_release" ("projectId");

        -- Add foreign keys
        ALTER TABLE "project_release"
            ADD CONSTRAINT "fk_project_release_project_id"
            FOREIGN KEY ("projectId") REFERENCES "project"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        ALTER TABLE "project_release"
            ADD CONSTRAINT "fk_project_release_imported_by"
            FOREIGN KEY ("importedBy") REFERENCES "user"("id")
            ON DELETE SET NULL ON UPDATE NO ACTION;

        ALTER TABLE "project_release"
            ADD CONSTRAINT "fk_project_release_file_id"
            FOREIGN KEY ("fileId") REFERENCES "file"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: project_release';
    ELSE
        RAISE NOTICE 'Table project_release already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- 11. PLATFORM_ANALYTICS_REPORT TABLE
-- =====================================================
-- Based on migration 1753091760355-AddPlatformAnalyticsReportEntity
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'platform_analytics_report') THEN
        CREATE TABLE "platform_analytics_report" (
            "id" character varying(21) NOT NULL,
            "created" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "updated" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
            "platformId" character varying NOT NULL,
            "totalFlows" integer NOT NULL,
            "activeFlows" integer NOT NULL,
            "totalUsers" integer NOT NULL,
            "activeUsers" integer NOT NULL,
            "totalProjects" integer NOT NULL,
            "activeProjects" integer NOT NULL,
            "uniquePiecesUsed" integer NOT NULL,
            "activeFlowsWithAI" integer NOT NULL,
            "topPieces" jsonb NOT NULL,
            "tasksUsage" jsonb NOT NULL,
            "topProjects" jsonb NOT NULL,
            CONSTRAINT "REL_d2a0169d4bc6ede39dc05c9ca0" UNIQUE ("platformId"),
            CONSTRAINT "PK_8b060dc8b2e5d9d91162ce2cc11" PRIMARY KEY ("id")
        );

        -- Add foreign key
        ALTER TABLE "platform_analytics_report"
            ADD CONSTRAINT "fk_platform_analytics_report_platform_id"
            FOREIGN KEY ("platformId") REFERENCES "platform"("id")
            ON DELETE CASCADE ON UPDATE NO ACTION;

        RAISE NOTICE 'Created table: platform_analytics_report';
    ELSE
        RAISE NOTICE 'Table platform_analytics_report already exists, skipping...';
    END IF;
END $$;

-- =====================================================
-- REGISTER MIGRATIONS IN migrations TABLE
-- =====================================================
-- This ensures TypeORM knows these migrations have been run

INSERT INTO "migrations" ("timestamp", "name") VALUES
    (1698602417745, 'AddSigningKey1698602417745'),
    (1698698190965, 'AddDisplayNameToSigningKey1698698190965'),
    (1699221414907, 'AddOAuth2AppEntiity1699221414907'),
    (1700396157624, 'AddOtpEntity1700396157624'),
    (1701084418793, 'AddStateToOtp1701084418793'),
    (1701647565290, 'ModifyProjectMembersAndRemoveUserId1701647565290'),
    (1703411318826, 'AddPlatformIdToFlowTemplates1703411318826'),
    (1704503804056, 'AddGitRepoMigrationPostgres1704503804056'),
    (1707614902283, 'AddAuditEvents1707614902283'),
    (1709151540095, 'AddSlugToGitRepo1709151540095'),
    (1709753080714, 'AddMappingStateToGit1709753080714'),
    (1711073772867, 'AddBranchTypeToGit1711073772867'),
    (1731424289830, 'CreateProjectRoleTable1731424289830'),
    (1731711188507, 'AddAuditLogIndicies1731711188507'),
    (1734418823028, 'CreateProjectReleaseTable1734418823028'),
    (1753091760355, 'AddPlatformAnalyticsReportEntity1753091760355')
ON CONFLICT ("timestamp") DO NOTHING;

-- =====================================================
-- VERIFY ALL TABLES WERE CREATED
-- =====================================================
DO $$
DECLARE
    table_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO table_count
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
    );

    RAISE NOTICE '====================================';
    RAISE NOTICE 'Created/Verified % out of 11 EE tables', table_count;
    RAISE NOTICE '====================================';

    IF table_count = 11 THEN
        RAISE NOTICE 'SUCCESS: All EE tables are present!';
    ELSE
        RAISE NOTICE 'WARNING: Not all tables were created. Please check the logs above.';
    END IF;
END $$;

COMMIT;

-- =====================================================
-- SCRIPT COMPLETE
-- =====================================================
-- All Enterprise Edition tables have been created or verified.
-- Foreign key constraints have been added.
-- Migrations have been registered in the migrations table.
-- =====================================================
