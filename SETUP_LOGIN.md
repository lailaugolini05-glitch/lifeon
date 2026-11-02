# Switching on sign-in (Google, Apple, email)

LifeOn uses Supabase for accounts. It is free for a pilot.

1. Create a free account at supabase.com and a new project (region: Europe).
2. In the project: SQL Editor -> New query, paste this and press Run:

```sql
create table if not exists public.players (
  id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz default now()
);
alter table public.players enable row level security;
create policy "read own" on public.players for select using (auth.uid() = id);
create policy "insert own" on public.players for insert with check (auth.uid() = id);
create policy "update own" on public.players for update using (auth.uid() = id);
create policy "delete own" on public.players for delete using (auth.uid() = id);
```

3. Authentication -> URL Configuration: set Site URL to
   https://lailaugolini05-glitch.github.io/lifeon/ and add the same address to Redirect URLs.
4. Email sign-in works straight away.
5. Google: Authentication -> Providers -> Google. It needs a Client ID and secret from
   Google Cloud Console (APIs & Services -> Credentials -> OAuth client ID, type "Web application",
   authorised redirect URI = the callback URL Supabase shows on that page).
6. Apple: Authentication -> Providers -> Apple. It needs a paid Apple Developer account (99 USD/year).
7. Project Settings -> API: copy the Project URL and the "anon public" key and send them to Claude.
   (The anon key is meant to be public; never share the "service_role" key.)
