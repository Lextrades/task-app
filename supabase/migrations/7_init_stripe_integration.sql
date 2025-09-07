-- Stripe integration schema (no foreign data wrapper needed)
-- Stripe customers are now created on-demand in Edge Functions
create schema stripe;




-- Security policy: Users can read their own Stripe data
create policy "Users can read own Stripe data"
  on public.profiles
  for select
  using (auth.uid() = user_id);
