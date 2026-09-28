-- Backend schema scaffold. Apply only through a linked Supabase project.
-- All player-owned writes are deliberately server-side until score validation exists.

begin;

create table public.daily_challenges (
  challenge_date date primary key,
  puzzle_version text not null check (char_length(puzzle_version) between 1 and 64),
  puzzle_seed bigint not null check (puzzle_seed between 0 and 4294967295),
  rules jsonb not null default '{}'::jsonb check (jsonb_typeof(rules) = 'object'),
  published_at timestamptz not null,
  created_at timestamptz not null default now()
);

create table public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table public.daily_challenge_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  challenge_date date not null references public.daily_challenges(challenge_date),
  score integer not null check (score >= 0),
  move_count integer not null check (move_count >= 0),
  completed_at timestamptz not null default now(),
  primary key (user_id, challenge_date)
);

create table public.user_leaf_ledger (
  user_id uuid not null references auth.users(id) on delete cascade,
  source_key text not null check (char_length(source_key) between 1 and 128),
  amount integer not null check (amount <> 0),
  source_type text not null check (char_length(source_type) between 1 and 64),
  created_at timestamptz not null default now(),
  primary key (user_id, source_key)
);

create table public.user_owned_items (
  user_id uuid not null references auth.users(id) on delete cascade,
  item_id text not null check (char_length(item_id) between 1 and 128),
  acquired_at timestamptz not null default now(),
  primary key (user_id, item_id)
);

create table public.user_garden_placements (
  user_id uuid not null references auth.users(id) on delete cascade,
  slot_id integer not null check (slot_id >= 0),
  item_id text not null check (char_length(item_id) between 1 and 128),
  placed_at timestamptz not null default now(),
  primary key (user_id, slot_id),
  unique (user_id, item_id),
  foreign key (user_id, item_id)
    references public.user_owned_items(user_id, item_id)
    on delete cascade
);

alter table public.daily_challenges enable row level security;
alter table public.user_profiles enable row level security;
alter table public.daily_challenge_progress enable row level security;
alter table public.user_leaf_ledger enable row level security;
alter table public.user_owned_items enable row level security;
alter table public.user_garden_placements enable row level security;

revoke all on table public.daily_challenges, public.user_profiles,
  public.daily_challenge_progress, public.user_leaf_ledger,
  public.user_owned_items, public.user_garden_placements from anon, authenticated;

grant select on table public.daily_challenges to anon, authenticated;
grant select on table public.user_profiles, public.daily_challenge_progress,
  public.user_leaf_ledger, public.user_owned_items,
  public.user_garden_placements to authenticated;

create policy "published daily challenges are readable"
  on public.daily_challenges for select to anon, authenticated
  using (
    published_at <= now()
    and challenge_date <= (now() at time zone 'UTC')::date
  );

create policy "users read own profile"
  on public.user_profiles for select to authenticated
  using ((select auth.uid()) = id);

create policy "users read own daily progress"
  on public.daily_challenge_progress for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "users read own leaf ledger"
  on public.user_leaf_ledger for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "users read own owned items"
  on public.user_owned_items for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "users read own garden placements"
  on public.user_garden_placements for select to authenticated
  using ((select auth.uid()) = user_id);

create function public.create_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.user_profiles (id) values (new.id);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.create_user_profile();

revoke all on function public.create_user_profile() from public;

commit;
