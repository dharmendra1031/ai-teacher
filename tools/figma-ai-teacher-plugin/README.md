# AI Teacher UI Generator — Local Figma Plugin

A zero-network local Figma plugin that generates an editable UI foundation and Android MVP screens for the AI Teacher project.

## What it creates

The plugin is intentionally limited to three pages so it works with Figma Starter plan page limits:

1. `01 Foundations`
   - Color palette
   - Typography
   - Spacing scale
   - Radius and elevation examples

2. `02 Components`
   - Buttons
   - Inputs
   - Topic cards
   - Teacher card
   - Progress card
   - Report card
   - Live-call controls

3. `03 Screens`
   - Splash
   - Onboarding
   - Login
   - Home dashboard
   - Topic selection
   - Pre-call permissions
   - Live AI call
   - Session report
   - Progress
   - Profile and settings

All mobile screens use a `390 × 844` Android frame.

## Install in Figma Desktop

1. Download and extract this folder.
2. Open the **Figma Desktop app**.
3. Open any Figma Design file, preferably the `AI Teacher Mobile App UI` file.
4. Open:
   `Plugins → Development → Import plugin from manifest…`
5. Select this folder’s `manifest.json`.
6. Run:
   `Plugins → Development → AI Teacher UI Generator`
7. Click **Generate Full UI**.

## When Figma asks for a plugin ID

Most local development imports accept the included manifest directly. When your Figma installation requires an ID:

1. Open `Plugins → Development → New plugin…`
2. Choose **Figma design** and **Custom UI**.
3. Let Figma generate a starter plugin.
4. Copy the numeric `id` from the generated manifest into this plugin’s `manifest.json`.
5. Import this manifest again.

## Safe regeneration

The plugin tags every node it generates. The **Clear Generated Design** action removes only tagged nodes and preserves unrelated work.

Running a generate action again refreshes the corresponding page instead of duplicating generated content.

## Privacy and network

- No API key is required.
- No network request is made.
- `networkAccess.allowedDomains` is set to `none`.
- The plugin works only in the currently open Figma file.

## Files

- `manifest.json` — Figma plugin declaration
- `code.js` — design generator
- `ui.html` — local plugin control panel

## Current design direction

- Modern, clean and confidence-building
- Light product UI with a premium purple/blue identity
- Dark immersive live-call screen
- Inter typography
- Minimum 48px action targets
- Audio-only and privacy-first product messaging

## Development branch destination

Recommended repository location:

`tools/figma-ai-teacher-plugin/`
