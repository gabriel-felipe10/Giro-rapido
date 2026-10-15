-- Giro Rápido: execute este arquivo inteiro no Supabase (SQL Editor > New query > Run).

-- 1) Tabela com o documento do site (uma única linha, id = 1)
create table if not exists public.site_data (
  id int primary key check (id = 1),
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.site_data enable row level security;

-- Permissões da Data API (necessárias com "Automatically expose new tables" desligado).
-- O RLS abaixo continua limitando quem pode ler e escrever.
grant usage on schema public to anon, authenticated;
grant select on public.site_data to anon, authenticated;
grant insert, update on public.site_data to authenticated;

-- Qualquer visitante pode ler
drop policy if exists "leitura publica" on public.site_data;
create policy "leitura publica" on public.site_data
  for select using (true);

-- Só usuários logados (o administrador) podem criar/alterar
drop policy if exists "admin insere" on public.site_data;
create policy "admin insere" on public.site_data
  for insert to authenticated with check (true);

drop policy if exists "admin atualiza" on public.site_data;
create policy "admin atualiza" on public.site_data
  for update to authenticated using (true) with check (true);

-- 2) Bucket público para as fotos dos produtos
insert into storage.buckets (id, name, public)
values ('photos', 'photos', true)
on conflict (id) do nothing;

drop policy if exists "fotos leitura" on storage.objects;
create policy "fotos leitura" on storage.objects
  for select using (bucket_id = 'photos');

drop policy if exists "fotos upload admin" on storage.objects;
create policy "fotos upload admin" on storage.objects
  for insert to authenticated with check (bucket_id = 'photos');

drop policy if exists "fotos apaga admin" on storage.objects;
create policy "fotos apaga admin" on storage.objects
  for delete to authenticated using (bucket_id = 'photos');
