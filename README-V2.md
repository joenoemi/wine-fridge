# Cellar Notes V2 Upgrade

V2 lastes replaces magic-link sign-in with email/password login, creates a secure shared household cellar, replaces QR-oriented scanning with ZXing UPC/EAN scanning, checks your own cellar before public databases, checks both Open Food Facts and Open Products Facts, and adds on-device label OCR as a manual-entry assistant.

## Important limitations

Public barcode databases do not contain every wine. V2 follows this order:

1. Match the UPC in your shared Supabase cellar.
2. Query Open Food Facts.
3. Query Open Products Facts.
4. Open manual entry with the UPC retained.

Label OCR extracts visible text but does not provide commercial wine ratings or guaranteed wine identification. Review imported fields before saving.

## Upgrade steps

### 1. Back up V1

Download the current GitHub repository as a ZIP before replacing files.

### 2. Create the two password users

In Supabase, go to **Authentication > Users > Add user**. Create one user for Jose and one for Noemi with separate email addresses and passwords. Auto-confirm both users if the option appears.

In **Authentication > Sign In / Providers**:

- Email provider: enabled
- Confirm email: disabled, if you want no initial confirmation email
- Anonymous sign-ins: disabled
- Public signups: disable after both users exist

### 3. Run the V2 migration

Open `setup-v2.sql`. Replace these exact placeholders:

```text
REPLACE_WITH_JOSE_EMAIL
REPLACE_WITH_NOEMI_EMAIL
```

Use the exact lower-case email addresses shown under Supabase Authentication > Users. Copy the entire SQL file into Supabase SQL Editor and select **Run** once.

If the migration says the users do not exist, confirm both Auth users were created first and that both email addresses were replaced correctly.

### 4. Preserve config.js

If your current `config.js` already works, keep its existing Supabase URL and publishable/anon key. Otherwise paste them into the V2 `config.js`. Never use the service_role key.

### 5. Replace GitHub files

Upload these V2 files to the root of the existing GitHub Pages repository and overwrite the old files:

```text
index.html
app.js
styles.css
config.js
manifest.json
service-worker.js
icon.svg
```

Also upload `setup-v2.sql` and `README-V2.md` for reference. Commit directly to the branch GitHub Pages deploys, normally `main`.

### 6. Clear the old cached app

V1 used a service worker, so an iPhone may continue showing the old email-link page temporarily.

1. Wait for GitHub Pages deployment to complete.
2. On iPhone, open Settings > Safari > Advanced > Website Data.
3. Search for `joenoemi.com` and delete its website data.
4. Close Safari completely.
5. Reopen `https://wine.joenoemi.com`.
6. If installed on the Home Screen, remove the old icon and add the site again after V2 loads.

### 7. Test password login and sharing

Sign in as Jose, add a test bottle, then sign out. Sign in as Noemi. The same bottle should be visible. Consume or restock it and verify the change appears for the other account.

### 8. Test UPC scanning

Use the center Scan button and allow camera access. Select a camera whose label includes Back, Rear, or Environment. Hold a UPC horizontally inside the guide, avoid glare, and fill most of the guide with the barcode. V2 accepts UPC-A (12 digits), EAN-13 (13 digits), and EAN-8 (8 digits).

### 9. Configure final Supabase URLs

In **Authentication > URL Configuration** set:

```text
Site URL: https://wine.joenoemi.com
Redirect URL: https://wine.joenoemi.com/**
```

Password sign-in does not use a redirect, but password reset does.

## Troubleshooting

### Login still says email link

The old service worker is cached or V2 was not deployed to the Pages branch. Clear website data as described above and verify GitHub Actions shows a successful Pages deployment.

### Scanner opens but does not read

Use the rear camera, hold the phone 6 to 10 inches away, avoid curved glare, keep the full barcode visible, and try brighter indirect light. QR codes are not the target in V2. The scanner uses multi-format ZXing decoding.

### Lookup says no public product match

The barcode is absent from both public databases. Enter the wine manually. Once saved, future scans of that UPC match your Supabase cellar immediately.

### User has not been added to a household

Run `setup-v2.sql` after replacing both email placeholders. Do not run the household creation block repeatedly because each run creates another household.
