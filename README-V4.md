# Cellar Notes V4 Upgrade Guide

V4 adds optional FastCork wine-label recognition through a Supabase Edge Function. The FastCork API key never appears in GitHub or browser code. If FastCork is canceled, out of credits, unconfigured, or unavailable, Cellar Notes continues to support password login, shared inventory, UPC scanning, bottle photos, on-device OCR, manual entry, ratings, shopping lists, and recommendations.

## Files

- `index.html`, `app.js`, `styles.css`: V4 web app
- `supabase/functions/fastcork-analyze/index.ts`: secure server-side FastCork proxy
- `supabase/functions/fastcork-analyze/config.toml`: requires a valid Supabase JWT
- `setup-v4.sql`: informational check only
- `config.js`: retain your current Supabase URL and publishable key

## Step 1: Buy FastCork access and copy the key

Create the FastCork API key from its dashboard. Treat the key as a secret. Do not paste it into `config.js`, `app.js`, GitHub, or Supabase SQL.

## Step 2: Install the Supabase CLI

On macOS with Homebrew:

```bash
brew install supabase/tap/supabase
```

Alternatively, follow the official Supabase CLI installation method for your operating system.

## Step 3: Sign in and link the project

From Terminal, change into the extracted V4 folder and run:

```bash
supabase login
supabase link --project-ref YOUR_PROJECT_REFERENCE
```

Find the project reference in the Supabase dashboard URL or Project Settings. Do not use the full project URL in place of the reference.

## Step 4: Save the FastCork key as a secret

```bash
supabase secrets set FASTCORK_API_KEY="fc-your-real-key"
```

The secret is stored on Supabase, not GitHub.

## Step 5: Deploy the Edge Function

From the V4 folder:

```bash
supabase functions deploy fastcork-analyze
```

The included function requires an authenticated Supabase session and forwards only the label image to FastCork.

## Step 6: Preserve config.js

Copy the working values from the currently deployed V3 `config.js` into the V4 file:

```javascript
window.CELLAR_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-PUBLISHABLE-KEY"
};
```

Never use the Supabase service-role key or the FastCork key here.

## Step 7: Upload V4 to GitHub

Upload the root web files to the existing GitHub Pages repository and replace the earlier versions. The `supabase` folder and documentation can also remain in the repository because the function source contains no secret.

Commit to the branch used by GitHub Pages, normally `main`, and wait for deployment.

## Step 8: Clear the V3 cache

On iPhone, clear website data for `joenoemi.com` under Settings > Safari > Advanced > Website Data. Fully close Safari, reopen `https://wine.joenoemi.com`, and replace the Home Screen shortcut if necessary.

## Step 9: Test FastCork

1. Sign in.
2. Open Settings and select **Test FastCork connection**.
3. The status should say FastCork is configured.
4. Select **Scan label**.
5. Take a clear front-label photo.
6. Select **Identify wine with FastCork**.
7. Review every populated field before saving.

## Cancellation and fallback

If FastCork is canceled, the Edge Function returns a friendly unavailable or credit error. Cellar Notes does not fail. Use **on-device text extraction** or manual entry. Existing wines, photos, ratings, inventory, and shopping lists remain in Supabase.

To disable FastCork deliberately without changing the app:

```bash
supabase secrets unset FASTCORK_API_KEY
```

The Settings status then reports that FastCork is not configured.

## Security notes

- Never call FastCork directly from GitHub Pages because that exposes the API key to every visitor.
- Never store the key in `config.js`, localStorage, Supabase tables, or browser developer settings.
- The Edge Function validates authentication, file type, and a 5 MB file-size limit.
- FastCork results are suggestions. Review name, vintage, region, grape, price, and notes before saving.


## Required V4 database migration

Before using FastCork, run `setup-v4.sql` in Supabase SQL Editor. It adds dedicated columns for appellation, alcohol percentage, tasting notes, food pairings, serving temperature, decanting, recognition metadata, and the complete FastCork JSON response.

## V4 detail layout

The first bottle screen shows the photo, name, vintage, region, rating, quantity, price, rack, UPC, and inventory actions. Select **More wine details** for appellation, grapes, alcohol, tasting profile, serving temperature, decanting guidance, food pairings, recognition source, recognition date, confidence, and the raw provider response. The Add/Edit form uses **Show additional wine information** to expose the same advanced fields without cluttering the normal mobile workflow.

The complete FastCork response is saved in `fastcork_raw_data`, so fields are not lost if the provider adds new content or the subscription is later canceled.
