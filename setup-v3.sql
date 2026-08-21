-- Cellar Notes V3: bottle-photo storage
-- Run after setup-v2.sql.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('wine-images','wine-images',true,5242880,array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp'];

drop policy if exists "Household members upload wine images" on storage.objects;
create policy "Household members upload wine images" on storage.objects for insert to authenticated
with check (bucket_id='wine-images' and exists(
 select 1 from public.household_members hm
 where hm.user_id=(select auth.uid()) and hm.household_id::text=(storage.foldername(name))[1]
));

drop policy if exists "Household members update wine images" on storage.objects;
create policy "Household members update wine images" on storage.objects for update to authenticated
using (bucket_id='wine-images' and exists(
 select 1 from public.household_members hm
 where hm.user_id=(select auth.uid()) and hm.household_id::text=(storage.foldername(name))[1]
));

drop policy if exists "Household members delete wine images" on storage.objects;
create policy "Household members delete wine images" on storage.objects for delete to authenticated
using (bucket_id='wine-images' and exists(
 select 1 from public.household_members hm
 where hm.user_id=(select auth.uid()) and hm.household_id::text=(storage.foldername(name))[1]
));
