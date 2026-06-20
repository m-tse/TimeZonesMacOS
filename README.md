# Meridian

A lightweight macOS menubar app for viewing multiple timezones at a glance. Inspired by [time.fyi/timezones](https://time.fyi/timezones).

![Screenshot](screenshot.png)

## Why

Most timezone apps just show you the current time in different cities. That's not very useful — you can Google that. What you actually need is to answer questions like "if I schedule a call for 3pm my time, what time is that for them?" or "what time was it in Tokyo when that incident fired at 2am?" This app lets you drag a time ruler and see all your cities update simultaneously, so you can scrub forward or backward through the day and instantly see the answer.

It's also designed to be dead simple to read. Day and night hours are visually distinct, date changes are color-coded, and hour deltas are shown relative to whichever city you click — no mental math required.

## Features

- **Menubar app** — lives in your menubar, one click to open
- **Multiple timezones** — add cities from a curated list of 75+ worldwide locations with search aliases (e.g. search "cape town" finds Johannesburg, South Africa)
- **Draggable time ruler** — each city has a timeline bar with a `<>` handle you can drag to scrub through the full 24 hours, updating all cities simultaneously
- **Day/night visualization** — timeline ticks are light for daytime hours (6am-6pm) and dark for nighttime
- **Reference city** — click any city row to set it as your reference point; hour deltas and date coloring adjust relative to the selected city (city name shown in bold)
- **Rename cities** — right-click any city and choose "Rename" to give it a custom alias (e.g. rename "Johannesburg, South Africa" to "Cape Town, SA (Mustapha)")
- **Jump to date** — click the underlined date on any row to open a date picker and see all timezones on a future or past date
- **Date indicators** — each city shows its current date, colored red if behind your reference city's day, green if ahead
- **Hour delta** — shows the offset from your reference city (e.g. `-6h`, `+1h`)
- **Auto-sorted** — cities are always ordered by UTC offset (west to east)
- **Blinking colon** — subtle animated colon separator in the time display
- **Resizable panel** — drag the bottom handle to adjust the panel height; your preference is saved across launches
- **Persistent settings** — your timezone list, renames, and panel height are saved via UserDefaults
- **Reset to Now** — one-click reset when you've scrubbed away from the current time
- **Double-click reset** — double-click any timeline bar to reset to the current time

## Install

### Homebrew

```bash
brew install m-tse/tap/meridian
```

The app is signed and notarized with an Apple Developer ID.

### Update

```bash
brew update && brew upgrade --cask meridian
```

### From source

Requires macOS 13.0+, Apple Silicon (arm64), and Xcode command line tools.

```bash
./build.sh
open 'Meridian.app'
```

A globe icon will appear in your menubar. Click it to open the timezone panel.

## Usage

- **Add a timezone** — click "+ Add" at the bottom, search by city name, country, or alias
- **Remove a timezone** — right-click a city row and select "Remove"
- **Rename a timezone** — right-click a city row and select "Rename"
- **Scrub time** — drag the `<>` circle on any city's timeline bar
- **Jump to a date** — click the underlined date (e.g. "Mar 26") on any row
- **Change reference city** — click any city row to highlight it and reorient all deltas
- **Reset** — click "Reset" to return to the current time
- **Resize** — drag the handle at the very bottom of the panel

## Releasing

### Prerequisites (one-time setup)

1. Install a **Developer ID Application** certificate via Xcode → Settings → Accounts → Manage Certificates → "+" → "Developer ID Application"
2. Generate an **app-specific password** at [appleid.apple.com](https://appleid.apple.com) → Sign-In and Security → App-Specific Passwords
3. Store notarization credentials in the Keychain:

```bash
xcrun notarytool store-credentials "notarytool" --apple-id <your-apple-id> --team-id <your-team-id>
```

### Cutting a release

1. Bump the version in `Info.plist` (`CFBundleVersion` and `CFBundleShortVersionString`)
2. Build, sign, notarize, and staple:

```bash
./build.sh

codesign --deep --force --options runtime \
  --sign "Developer ID Application: ImprovMX Incorporated (2TMRXZB6JT)" \
  Meridian.app

codesign -vvv --deep --strict Meridian.app

ditto -c -k --keepParent Meridian.app Meridian-<version>.zip

xcrun notarytool submit Meridian-<version>.zip \
  --keychain-profile "notarytool" --wait

xcrun stapler staple Meridian.app

ditto -c -k --keepParent Meridian.app Meridian-<version>.zip
```

3. Create the GitHub release:

```bash
gh release create v<version> Meridian-<version>.zip --title "v<version>"
```

4. Update the Homebrew cask in [m-tse/homebrew-tap](https://github.com/m-tse/homebrew-tap) — set the new version and `sha256` (from `shasum -a 256 Meridian-<version>.zip`)
