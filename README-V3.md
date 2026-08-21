# Cellar Notes V3 Upgrade

V3 keeps the V2 password login, shared household inventory, and ZXing UPC/EAN scanner while adding secure bottle-photo uploads and a stricter mobile-first layout. The scan icon is now CSS-rendered instead of a distorted text glyph.

## Install

1. Complete the V2 Supabase household migration first.
2. In Supabase SQL Editor, run the entire `setup-v3.sql` file once. This creates the public `wine-images` bucket with authenticated household upload, update, and delete policies.
3. Preserve the working Supabase values in `config.js`. The V3 ZIP contains placeholders, so copy the Project URL and publishable/anon key from the current working file. Never use the service-role key.
4. Upload all V3 files to the root of the GitHub Pages repository and overwrite the earlier files.
5. Wait for the GitHub Pages deployment to complete.
6. On iPhone, clear website data for `joenoemi.com` under Settings > Safari > Advanced > Website Data. Remove and re-add the Home Screen shortcut if needed.
7. Open `https://wine.joenoemi.com`. The app should fit the viewport without pinching.

## Bottle photo workflow

Open Add or Edit Wine and select **Take bottle photo** or **Choose photo**. The browser compresses the image to JPEG, with a longest side of 1,400 pixels and approximately 82% quality, before uploading. The photo is stored under a household-specific path in the Supabase `wine-images` bucket.

The **Scan label** workflow also uses the selected label image as the bottle photo after OCR. Review the recognized text before saving.

## UPC lookup behavior

V3 first checks the shared cellar, then Open Food Facts, then Open Products Facts. If no public match exists, the form opens with the UPC retained. Add the bottle photo and details once. Future scans of the same UPC will match the shared cellar and add another bottle.

## Mobile fixes

- Full-width mobile viewport and dynamic viewport-height support
- Horizontal overflow prevention
- Mobile-sized dialogs and scanner frame
- Responsive one-column form fields on narrow screens
- Properly constrained video, image, and canvas elements
- New barcode icon that does not depend on a Unicode glyph
- Safe-area padding for iPhone Home Screen mode

## If the page still looks zoomed

The old service worker is still cached. Clear Safari website data for `joenoemi.com`, fully close Safari, reopen the site, and add the site back to the Home Screen.
