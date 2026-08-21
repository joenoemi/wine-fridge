# Cellar Notes: Personal Wine Fridge

A mobile-first personal wine inventory for GitHub Pages and Supabase. It includes iPhone UPC scanning, editable wine information and pricing, inventory history, consumption tracking, personal ratings, automatic restock lists, and taste-based recommendations.

## What is included

- `index.html`: Application interface
- `app.js`: Supabase, barcode lookup, inventory, rating, and recommendation logic
- `styles.css`: Mobile-first design
- `config.js`: Your two public Supabase project values
- `setup.sql`: Tables, indexes, Row Level Security, and validation trigger
- `manifest.json`, `service-worker.js`, `icon.svg`: Installable iPhone web app files

## Before starting

You need:

1. A free GitHub account.
2. A free Supabase account.
3. An email address for passwordless sign-in.
4. An iPhone with Safari for scanning and Home Screen installation.

Do not place a Supabase `service_role` key in this project. Only use the browser-safe publishable key or legacy `anon` key.

# Installation

## Step 1: Create the Supabase project

1. Sign in to Supabase.
2. Select **New project**.
3. Give it a name such as `cellar-notes`.
4. Create a strong database password and save it securely. The web app does not use this password.
5. Select a nearby region and create the project.
6. Wait for the project to finish provisioning.

## Step 2: Create the database

1. In Supabase, open **SQL Editor**.
2. Select **New query**.
3. Open the included `setup.sql` file.
4. Copy the entire file and paste it into the SQL Editor.
5. Select **Run**.
6. Confirm that the query completed successfully.

The SQL enables Row Level Security. Each signed-in person can only read and modify rows carrying their own Supabase user ID.

## Step 3: Configure passwordless email login

1. In Supabase, open **Authentication > Providers**.
2. Confirm that the **Email** provider is enabled.
3. Leave email OTP or magic-link sign-in enabled.
4. You can disable new-user sign-ups after your own account has signed in once if this app is strictly personal.

## Step 4: Create the GitHub repository

1. Sign in to GitHub.
2. Select **New repository**.
3. Name it `cellar-notes`.
4. Choose **Private** or **Public**. GitHub Pages availability for private repositories depends on your GitHub plan, so a public repository is the simplest free option.
5. Create the repository.
6. Select **Add file > Upload files**.
7. Upload every file from this ZIP, but do not upload the ZIP itself.
8. Commit the files to the `main` branch.

The Supabase publishable/anon key is designed for browser applications. Security comes from the included Row Level Security policies, not from concealing that public key.

## Step 5: Add your Supabase project values

1. In Supabase, open **Project Settings > API**.
2. Copy the **Project URL**.
3. Copy the **Publishable key**. If your project only shows legacy keys, use the `anon public` key.
4. In GitHub, open `config.js` and select the pencil icon.
5. Replace the two placeholders:

```javascript
window.CELLAR_CONFIG = {
  SUPABASE_URL: "https://YOUR-PROJECT.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-PUBLISHABLE-OR-ANON-KEY"
};
```

6. Commit the change.

Never paste the `service_role` or secret key into `config.js`.

## Step 6: Enable GitHub Pages

1. In the GitHub repository, open **Settings > Pages**.
2. Under **Build and deployment**, select **Deploy from a branch**.
3. Select branch `main` and folder `/ (root)`.
4. Select **Save**.
5. Wait a few minutes for deployment.
6. GitHub will display a URL similar to:

```text
https://YOUR-GITHUB-NAME.github.io/cellar-notes/
```

## Step 7: Add the GitHub URL to Supabase

1. Copy the exact GitHub Pages URL.
2. In Supabase, open **Authentication > URL Configuration**.
3. Set **Site URL** to your GitHub Pages URL.
4. Under **Redirect URLs**, add the same URL followed by `**`:

```text
https://YOUR-GITHUB-NAME.github.io/cellar-notes/**
```

5. Save the settings.

This allows the email magic link to return you to the deployed application.

## Step 8: First sign-in

1. Open the GitHub Pages URL in Safari.
2. Enter your email address.
3. Select **Email me a sign-in link**.
4. Open the message on the same iPhone and select the link.
5. The app loads your private cellar.
6. If the app is strictly for you, return to Supabase Authentication settings and disable new-user sign-ups after your account exists.

## Step 9: Install it on the iPhone Home Screen

1. Open the app URL in Safari.
2. Select the Safari **Share** button.
3. Select **Add to Home Screen**.
4. Name it `Cellar Notes` and select **Add**.
5. Launch it from the new icon.

Camera access requires HTTPS. GitHub Pages supplies HTTPS automatically.

# Using the application

## Add with the camera

1. Select the center **Scan** button.
2. Allow camera permission.
3. Choose the rear camera if prompted.
4. Hold the bottle's UPC inside the frame.
5. The app checks Open Food Facts.
6. Review all imported details. Complete the vintage, type, price, rack, target quantity, and taste information.
7. Select **Save wine**.

Barcode records can be incomplete. If a UPC is not found, the form opens for manual entry while retaining the scanned UPC.

## Add manually

Open the scanner and select **Wine not found? Add it manually**. You can also use manual UPC entry.

## Record consumption

1. Open **Cellar**.
2. Select a wine.
3. Select **Mark consumed**.

The quantity is reduced and an inventory transaction is recorded.

## Rate a wine

Edit a wine and choose a personal rating from 1 to 5. Add body, sweetness, acidity, tannin, flavor tags, and tasting notes. Wines rated 4 or 5 influence the **For You** screen.

## Build the shopping list

Set a target quantity for each wine. When current quantity falls below the target, the wine automatically appears under **Buy**. Select **Copy shopping list** to paste it into Notes, Messages, or another app.

# Approximate price and external ratings

A dependable free UPC service does not normally provide live retailer pricing or licensed critic reviews. Therefore:

- The app imports basic product information from Open Food Facts when available.
- Approximate price is intentionally editable.
- External source and score are optional manual fields.
- Personal ratings and tasting profiles are stored in your Supabase database.
- The app does not scrape commercial wine-review websites.

# Troubleshooting

## Email button does nothing

Confirm that `config.js` contains the project URL and publishable/anon key, then wait for GitHub Pages to redeploy. Hard-refresh Safari or remove and reopen the Home Screen app.

## Magic link returns to the wrong place

Confirm the Supabase **Site URL** and **Redirect URLs** exactly match the GitHub Pages address, including the repository path and trailing slash.

## Camera does not open

- Use the deployed HTTPS GitHub Pages URL, not a local file.
- In iPhone Settings, allow Safari camera access.
- Close and reopen the scanner.
- Use manual UPC entry if camera access is blocked.

## UPC is not found

This is expected for some wines. Choose manual entry. The UPC is preserved so future scans can find the wine in your own cellar after it has been saved.

## Changed files do not appear

GitHub Pages and the service worker may cache an older version. Wait for the Pages deployment to finish, then refresh Safari. If necessary, remove the Home Screen app, clear Safari website data for the site, and add it again.

# Security checklist

- Keep Row Level Security enabled.
- Never use the Supabase `service_role` key in browser code.
- Disable new-user sign-ups after your account is created if this is personal-only.
- Do not store card details or other sensitive financial data in wine notes.
- Keep the repository free of private secrets.
