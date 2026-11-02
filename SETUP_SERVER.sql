-- LifeOn database (Supabase). Paste everything in: SQL Editor -> New query -> Run.

create table if not exists public.team_members (uid uuid primary key references auth.users(id) on delete cascade);
create or replace function public.is_team() returns boolean language sql stable security definer set search_path = public
  as $$ select exists (select 1 from public.team_members where uid = auth.uid()) $$;

create table if not exists public.players   (id uuid primary key references auth.users(id) on delete cascade, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.merchants (id text primary key, owner uuid references auth.users(id) on delete set null, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.billing   (id text primary key, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.teamkeys  (id text primary key, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.groups    (id text primary key, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.invites   (id text primary key, owner uuid references auth.users(id) on delete cascade, data jsonb not null default '{}', updated_at timestamptz default now());
create table if not exists public.private   (owner uuid references auth.users(id) on delete cascade, key text, data jsonb, primary key (owner, key));

alter table public.team_members enable row level security;
alter table public.players   enable row level security;
alter table public.merchants enable row level security;
alter table public.billing   enable row level security;
alter table public.teamkeys  enable row level security;
alter table public.groups    enable row level security;
alter table public.invites   enable row level security;
alter table public.private   enable row level security;

create policy "team sees team"   on public.team_members for select to authenticated using (true);

create policy "players read"     on public.players for select to authenticated using (true);
create policy "players own ins"  on public.players for insert to authenticated with check (id = auth.uid());
create policy "players own upd"  on public.players for update to authenticated using (id = auth.uid());
create policy "players own del"  on public.players for delete to authenticated using (id = auth.uid());

create policy "shops read"       on public.merchants for select to anon, authenticated using (true);
create policy "shops ins"        on public.merchants for insert to authenticated with check ((id = auth.uid()::text and owner = auth.uid()) or public.is_team());
create policy "shops upd"        on public.merchants for update to authenticated using (owner = auth.uid() or public.is_team());
create policy "shops del"        on public.merchants for delete to authenticated using (owner = auth.uid() or public.is_team());

create policy "billing read"     on public.billing for select to authenticated using (true);
create policy "billing team ins" on public.billing for insert to authenticated with check (public.is_team());
create policy "billing team upd" on public.billing for update to authenticated using (public.is_team());
create policy "billing team del" on public.billing for delete to authenticated using (public.is_team());

create policy "keys team"        on public.teamkeys for all to authenticated using (public.is_team()) with check (public.is_team());

create policy "groups read"      on public.groups for select to authenticated using (true);
create policy "groups ins"       on public.groups for insert to authenticated with check (true);
create policy "groups upd"       on public.groups for update to authenticated using (true);
create policy "groups del"       on public.groups for delete to authenticated using (data->>'createdBy' = auth.uid()::text);

create policy "invites read"     on public.invites for select to authenticated using (true);
create policy "invites ins"      on public.invites for insert to authenticated with check (owner = auth.uid());
create policy "invites upd"      on public.invites for update to authenticated using (true);
create policy "invites del"      on public.invites for delete to authenticated using (owner = auth.uid());

create policy "private own"      on public.private for all to authenticated using (owner = auth.uid()) with check (owner = auth.uid());

alter publication supabase_realtime add table public.players, public.merchants, public.billing, public.groups, public.invites;

-- AFTER you have signed in to LifeOn once, run this line (with your email) to become a team admin:
-- insert into public.team_members (uid) select id from auth.users where email = 'YOUR_EMAIL_HERE';
