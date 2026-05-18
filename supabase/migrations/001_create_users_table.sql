create table public.users (
  id          uuid        not null references auth.users(id) on delete cascade,
  email       text        not null,
  full_name   text        not null default '',
  phone       text        not null default '',
  avatar_url  text        not null default '',
  role        text        not null default 'user' check (role in ('user', 'admin')),
  created_at  timestamptz not null default now(),

  constraint users_pkey primary key (id)
);


alter table public.users enable row level security;

create policy "users: select own row"
  on public.users
  for select
  using (auth.uid() = id);

create policy "users: update own row"
  on public.users
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "admin: select all users"
  on public.users
  for select
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  );

 create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();create table public.users (
  id          uuid        not null references auth.users(id) on delete cascade,
  email       text        not null,
  full_name   text        not null default '',
  phone       text        not null default '',
  avatar_url  text        not null default '',
  role        text        not null default 'user' check (role in ('user', 'admin')),
  created_at  timestamptz not null default now(),

  constraint users_pkey primary key (id)
);


alter table public.users enable row level security;

create policy "users: select own row"
  on public.users
  for select
  using (auth.uid() = id);

create policy "users: update own row"
  on public.users
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "admin: select all users"
  on public.users
  for select
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  );

 create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email, full_name, avatar_url)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();