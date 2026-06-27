# Sideline repo conventions the generator must honor

Facts extracted from `code/sideline-health-hub-main` (verify they still hold when the skill
runs — schemas drift). The generator and templates are built around these.

## The two RLS shapes
1. **Org/tenant-scoped** (most tables: `treatment_macros`, `custom_forms`,
   `daily_treatment_notes`, `wellness_self_reports`, …). Policies key off the org via:
   - `is_org_member(auth.uid(), org_id)` — the common form; **`SECURITY DEFINER STABLE`**,
     and it **requires `active = true`**.
   - inline `org_id IN (select org_id from public.org_members where user_id = auth.uid())`
     — used by `custom_forms`; this variant **omits** the `active` check.
   → use the **org-isolation** template; default tenant column `org_id`.
2. **Owner-scoped** (`profiles`, `push_subscriptions`): `auth.uid() = id`.
   → use the **owner-scoped** template; for `profiles`, the owner column **is** the PK, so
   pass `--owner-col id --owner-is-pk`.

## org_members + the `active` flag (corrected — read this)
`org_members(org_id, user_id, role, active)`. `is_org_member()` requires `active = true`.
**That `true` comes from the COLUMN DEFAULT on `org_members.active`, NOT from the signup
trigger.** `handle_new_user_org` inserts `(org_id, user_id, role)` only — it never sets
`active`. So:
- Templates **seed `active = true` explicitly** (never rely on the trigger or the default
  being there). If a future migration drops that default, explicit seeding keeps tests valid.
- The inline `custom_forms` variant would let an **inactive** member pass — that semantic
  inconsistency is a finding for `supabase-security-reviewer`, **not** this skill. This skill
  tests each policy *as written*.

## auth.users signup triggers (side effects when minting a user)
`AFTER INSERT ON auth.users`: `handle_new_user` (creates a `profiles` row) and
`handle_new_user_org` (creates an `organizations` row + an owner `org_members` row). So
inserting a test user **auto-creates** a profile + org + membership.
- Org tests therefore seed **explicit** orgs/memberships with **literal ids** and assert by
  those ids; the trigger's auto-created rows are harmless noise.
- For `profiles` (owner test), the trigger **already creates** the row keyed on the new user
  id — the generator omits the manual seed (`--owner-is-pk`) and uses the user id as the row
  id. Read back / rely on the trigger row rather than inserting a duplicate.

## Migrations & tooling
- `supabase/migrations/` — files are `YYYYMMDDHHmmss_<uuid>.sql` (opaque names). **Parse the
  SQL (`CREATE POLICY … USING/WITH CHECK`), never the filename**, to learn intent.
- Package manager is **bun** (`bun run test`); CI uses bun — never `npm ci` (the
  `package-lock.json` is stale). `config.toml` holds only `project_id`; there is **no
  seed.sql**, so `supabase db start` applies migrations and that's the full fixture base.
- Default branch is **`Claude-Code-v1`** — there is no `main`. PRs base on it; follow the
  project `CLAUDE.md` dev-loop (CodeRabbit, `bunx tsc --noEmit`, `gh pr create --base
  Claude-Code-v1`). This skill **complements** `supabase-security-reviewer` (still mandated on
  every Supabase diff) — it does not replace it.
