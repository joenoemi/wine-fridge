-- CELLAR NOTES V2 - SHARED HOUSEHOLD MIGRATION
-- Run in Supabase SQL Editor after V1 setup.sql.
-- This creates a household shared by two or more authenticated users.

create table if not exists public.households (
 id uuid primary key default gen_random_uuid(), name text not null,
 created_by uuid not null references auth.users(id), created_at timestamptz not null default now()
);
create table if not exists public.household_members (
 household_id uuid not null references public.households(id) on delete cascade,
 user_id uuid not null references auth.users(id) on delete cascade,
 member_role text not null default 'member' check(member_role in ('owner','member')),
 created_at timestamptz not null default now(), primary key(household_id,user_id)
);

alter table public.wines add column if not exists household_id uuid references public.households(id) on delete cascade;
alter table public.wines add column if not exists created_by uuid references auth.users(id);
alter table public.inventory_transactions add column if not exists household_id uuid references public.households(id) on delete cascade;

alter table public.households enable row level security;
alter table public.household_members enable row level security;

drop policy if exists "Members view households" on public.households;
create policy "Members view households" on public.households for select to authenticated using (
 exists(select 1 from public.household_members m where m.household_id=id and m.user_id=(select auth.uid()))
);
drop policy if exists "Members view membership" on public.household_members;
create policy "Members view membership" on public.household_members for select to authenticated using (
 user_id=(select auth.uid()) or exists(select 1 from public.household_members m where m.household_id=household_members.household_id and m.user_id=(select auth.uid()))
);

-- Replace V1 per-user policies with household policies.
drop policy if exists "Users manage their wines" on public.wines;
drop policy if exists "Household members manage wines" on public.wines;
create policy "Household members manage wines" on public.wines for all to authenticated using (
 exists(select 1 from public.household_members m where m.household_id=wines.household_id and m.user_id=(select auth.uid()))
) with check (
 exists(select 1 from public.household_members m where m.household_id=wines.household_id and m.user_id=(select auth.uid()))
);
drop policy if exists "Users manage their transactions" on public.inventory_transactions;
drop policy if exists "Household members manage transactions" on public.inventory_transactions;
create policy "Household members manage transactions" on public.inventory_transactions for all to authenticated using (
 exists(select 1 from public.household_members m where m.household_id=inventory_transactions.household_id and m.user_id=(select auth.uid()))
) with check (
 user_id=(select auth.uid()) and exists(select 1 from public.household_members m where m.household_id=inventory_transactions.household_id and m.user_id=(select auth.uid()))
);

grant select on public.households,public.household_members to authenticated;
grant select,insert,update,delete on public.wines,public.inventory_transactions to authenticated;

-- AFTER both users exist, replace the two sample emails below and run this block once.
do $$
declare h uuid; jose uuid; noemi uuid;
begin
 select id into jose from auth.users where email=lower('REPLACE_WITH_JOSE_EMAIL');
 select id into noemi from auth.users where email=lower('REPLACE_WITH_NOEMI_EMAIL');
 if jose is null or noemi is null then raise exception 'Create both Auth users first and replace both email placeholders'; end if;
 insert into public.households(name,created_by) values('Jose and Noemi Wine Fridge',jose) returning id into h;
 insert into public.household_members(household_id,user_id,member_role) values(h,jose,'owner'),(h,noemi,'member');
 -- Migrate existing V1 data belonging to either account into the shared household.
 update public.wines set household_id=h,created_by=coalesce(created_by,user_id) where user_id in(jose,noemi);
 update public.inventory_transactions t set household_id=h where t.user_id in(jose,noemi);
end $$;

create index if not exists wines_household_idx on public.wines(household_id);
create index if not exists transactions_household_idx on public.inventory_transactions(household_id,created_at desc);
