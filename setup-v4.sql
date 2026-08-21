-- Cellar Notes V4 complete FastCork field migration
-- Run once after V2 and V3 setup scripts.
alter table public.wines add column if not exists appellation text;
alter table public.wines add column if not exists alcohol_percentage numeric(5,2) check (alcohol_percentage is null or alcohol_percentage between 0 and 100);
alter table public.wines add column if not exists tasting_notes text;
alter table public.wines add column if not exists food_pairings text[] not null default '{}';
alter table public.wines add column if not exists serving_temperature text;
alter table public.wines add column if not exists decanting_minutes integer check (decanting_minutes is null or decanting_minutes >= 0);
alter table public.wines add column if not exists serving_guidance text;
alter table public.wines add column if not exists recognition_provider text;
alter table public.wines add column if not exists recognition_confidence numeric(5,2) check (recognition_confidence is null or recognition_confidence between 0 and 100);
alter table public.wines add column if not exists recognized_at timestamptz;
alter table public.wines add column if not exists fastcork_raw_data jsonb;
create index if not exists wines_appellation_idx on public.wines(household_id,appellation);
create index if not exists wines_recognition_provider_idx on public.wines(household_id,recognition_provider);
select 'Cellar Notes V4 FastCork fields are ready.' as status;
