create policy if not exists "Allow profile creation for new users"
on public.profiles for insert
with check (auth.uid() = user_id);

create or replace function public.handle_new_user() 
returns trigger
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email));
  return new;
end;
$$ language plpgsql;
