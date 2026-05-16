create table public.categories (
  id          uuid        not null default gen_random_uuid(),
  name_en     text        not null,
  name_ar     text        not null,
  slug        text        not null,
  image_url   text        not null default '',
  parent_id   uuid            null references public.categories(id) on delete set null,
  is_active   boolean     not null default true,
  sort_order  integer     not null default 0,
  created_at  timestamptz not null default now(),

  constraint categories_pkey        primary key (id),
  constraint categories_slug_unique unique (slug)
);
create index categories_parent_id_idx   on public.categories (parent_id);
create index categories_is_active_idx   on public.categories (is_active);
create index categories_sort_order_idx  on public.categories (sort_order);

alter table public.categories enable row level security;

create policy "categories: public read"
  on public.categories
  for select
  using (is_active = true);

create policy "categories: admin insert"
  on public.categories
  for insert
  with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  );

create policy "categories: admin update"
  on public.categories
  for update
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  )
  with check (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  );

create policy "categories: admin delete"
  on public.categories
  for delete
  using (
    exists (
      select 1 from public.users u
      where u.id = auth.uid()
      and u.role = 'admin'
    )
  );