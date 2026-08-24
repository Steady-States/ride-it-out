# Handoff: Ride It Out — light & dark schemes

## Overview

Ride It Out is an iOS + watchOS crisis app for managing compulsive behavior. It has one job on its main screen: breathe with the user, show them the thing that grounds them, and put the people who will pick up two taps away.

The current build (`Steady-States/ride-it-out`, branch `main`) is dark-only — a navy ground (#0D0F1A) with a cyan accent and a blurred glow that crawls around the screen edge on every breath phase. Every view hard-codes `.preferredColorScheme(.dark)`.

This handoff covers a full re-skin into **two schemes — warm paper light and warm-ink dark** — plus four component-level changes. The screen structure does not change: the main screen keeps its 1/6 · 3/6 · 2/6 zone split, the four-slot lifeline grid, the three-stop guided tour, and the same settings hierarchy.

## About the design files

The files in this bundle are **design references created in HTML**. They are prototypes that show intended look and behavior — they are not production code and nothing in them should be copied into the app.

The target codebase is **SwiftUI** (iOS 17+ / watchOS, `@AppStorage`, `@StateObject`, `NavigationStack`). The task is to recreate these designs in that existing environment using its established patterns: the existing `Color` extension in `ride-it-out/Constants/Colors.swift`, the existing view files, the existing view models. Do not introduce a new styling layer.

Open `Ride It Out - light and dark.dc.html` in a browser to see the target. It renders every screen twice — light in the left column, dark in the right — with the real box-breathing timer running, so the phase colors and the trough animation are live rather than described.

`Current Build (dark).dc.html` is the existing app rebuilt from the Swift source at the same values. Use it as the before-picture when checking a diff.

## Fidelity

**High fidelity.** Colors, type sizes, weights, spacing, radii and timings below are final and exact. Two caveats:

- The HTML uses **Figtree** for UI text. In the app, keep the system font (`.system(size:weight:)`) as today — Figtree is the closest web stand-in for SF Pro and is not a font change request.
- Headline text in the HTML uses **Instrument Serif**. This IS a real change: see "Typography" below. Two alternates were explored and are switchable at the top of the HTML page; Instrument Serif is the pick unless told otherwise.
- The app icon is unchanged. A redesigned vector mark is shown in the HTML under "The mark" but is explicitly **parked** — ship the existing Hokusai icon.

---

## Design tokens

Replace the flat token list in `Colors.swift` with a scheme-aware pair per role. Suggested shape:

```swift
extension Color {
    static func scheme(_ light: Color, _ dark: Color) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }
    static let background = scheme(Color(hex: 0xF5EAD8), Color(hex: 0x17130F))
    // …
}
```

| Role | Light | Dark | Was (dark-only) |
| --- | --- | --- | --- |
| `background` | #F5EAD8 | #17130F | #0D0F1A |
| `surface` (breath band) | #EBDDC5 | #221C17 | #141729 |
| `surfaceRaised` (cards) | #F9F4ED | #2C251E | #1C2038 |
| `tint` (inset wells, segmented track) | #EEE7DB | #3A3129 | — |
| `borderColor` | rgba(32,30,29,0.14) | rgba(245,234,216,0.14) | #2A2D45 |
| `textPrimary` | #201E1D | #F5EAD8 | #F0F2FF |
| `textSecondary` | #645C50 | #A19786 | #8A8FAD |
| `textTertiary` | #82796A | #82796A | #555875 |
| `accent` (fills) | #C67139 | #F6A06B | #4FC3F7 |
| `accentOn` (text on accent fill) | #F9F4ED | #2E2B25 | #0D0F1A |
| `accentText` (accent as text/icon) | #8C491A | #F6A06B | #4FC3F7 |
| `accentFill` (tinted circle behind icon) | #FFE1D0 | #4A3325 | — |
| `sageFill` (lifeline tiles) | #E1EECC | #333A28 | #2E7D8C |
| `sageDeep` (avatars, tip button) | #56633F | #AEBF92 | — |
| `sageOn` (text on sageDeep) | #F0FAE1 | #272E1B | — |
| `sageText` (text on sageFill) | #3D472B | #CCDBB2 | — |
| `destructive` | #9C3B28 | #E0836F | #E05252 |
| `destructiveFill` | #F7DDD6 | #48281F | — |
| `scrim` (pill over media) | rgba(249,244,237,0.86) | rgba(44,37,30,0.88) | — |
| `scrimHeavy` (tour spotlight dim) | rgba(46,43,37,0.58) | rgba(10,8,6,0.68) | black 0.68 |
| `mediaWash` (over grounding photo) | rgba(245,234,216,0.22) | rgba(23,19,15,0.34) | — |
| `onMedia` (text over grounding photo) | #F9F4ED | #F5EAD8 | — |

### Breath-phase colors

Four phases, three values each — a solid edge-band color, a soft trough fill, and a text color for the phase label. Replaces `glowInhale/glowHoldIn/glowExhale/glowHoldOut`.

| Phase (`PhaseType`) | | Light | Dark |
| --- | --- | --- | --- |
| `.inhale` | band / fill / label | #C67139 / #FFE1D0 / #8C491A | #F6A06B / #3F2C1F / #F6A06B |
| `.holdAfterInhale` | | #8FA073 / #E1EECC / #56633F | #AEBF92 / #2F3626 / #CCDBB2 |
| `.exhale` | | #4A6F82 / #DBE6EC / #33566A | #8FB3C4 / #26333A / #A9CAD8 |
| `.holdAfterExhale` | | #A19786 / #EEE7DB / #645C50 | #82796A / #3A3129 / #A19786 |

The slate blue (#4A6F82 / #8FB3C4) is pulled from the app icon's ink wash and is the only hue outside the warm palette — it carries the exhale, which is the phase that should feel like cooling down.

### Radii, spacing, type

- Radii: **40** phone/screen corner (mock only), **28** cards and containers, **24** lifeline tiles and settings cards, **20** media placement box, **999** every button, pill, segmented control and toggle. Nothing above 8px squared off.
- Section label to card: 7px. Card to next section label: 9–13px. Card horizontal inset: 14px. Row padding: 12px vertical × 18px horizontal (10px vertical for two-line rows).
- Shadows: cards use none — separation comes from `surfaceRaised` against `background`. Only the tour card is elevated: `0 12px 32px rgba(46,43,37,0.32)`.

### Typography

Body and UI text stay on the system font at the sizes already in the source. One change: **screen titles and the wordmark move to a serif display face — Instrument Serif, regular (400).** Add it to the bundle as a custom font.

| Use | Face | Size | Notes |
| --- | --- | --- | --- |
| Welcome wordmark | Instrument Serif 400 | 46 | was system bold 40, tracking −1.2 |
| Screen titles ("Settings", "Lifelines", "Breathing", "Your anchor") | Instrument Serif 400 | 30–34 | was system heavy 30 |
| Tour card title | Instrument Serif 400 | 21 | was system bold 16 |
| Welcome tagline | system regular | 20 | line height 1.4, max ~15ch |
| Row label | system medium | 16 | was 14 |
| Row subtitle | system regular | 12 | color `textSecondary`, NOT tertiary — tertiary fails 4.5:1 at this size |
| Section label | system bold | 11 | tracking 1.4, uppercase, `textTertiary` |
| Beat counter | system light (300) | 54 | monospaced digits |
| Phase label | system bold | 11 | tracking 3, uppercase, phase label color |
| Body copy in cards | system regular | 13 | line height 1.5, `textSecondary` |

### Icons

The mock uses **Lucide** geometry at stroke-width 2.75 rather than SF Symbols, to match the rounder, heavier feel. Either import Lucide as assets or keep SF Symbols — if keeping SF Symbols, use `.symbolRenderingMode(.monochrome)` and weight `.semibold`, and keep the existing symbol names (`wind`, `photo.on.rectangle.angled`, `person.2.fill`, `bell.badge`, `play.circle`, `envelope`, `bubble.left.and.bubble.right.fill`, `lock.fill`, `trash`). Each settings row icon sits in a **34pt circle** filled with `accentFill` (or `sageFill` for Help rows, `destructiveFill` for the erase row), icon at 18pt in the matching text color.

---

## Screens

### 1. Welcome (`Views/Onboarding/WelcomeView.swift`)

**Purpose** — first launch. Two doors: help now, or set up first.

**Layout** — bottom-anchored column. A soft `tint` circle, 340pt diameter, bleeds off the top-right corner (center roughly x = +100, y = −120 from the top-right). Content is flush left at 28pt.

- App icon tile, 100×100, radius 24, shadow `0 3px 10px rgba(46,43,37,0.16)`. Use the existing Hokusai asset — **Default variant in light, Dark variant in dark**. 28pt below it:
- Wordmark "Ride It Out", Instrument Serif 46. 14pt below:
- Tagline "You don't have to fight the wave. You just have to stay on it." — system 20/1.4, `textSecondary`, wrapped to about 15 characters per line. 40pt below:
- Primary button: full width, height 60, radius 999, `accent` fill, `accentOn` text, system bold 18 — **"I need help right now"**.
- 12pt gap. Secondary button: same metrics, 1.5pt `accent` border, transparent fill, `accentText` label, system semibold 17 — **"Set up my ride"**.
- 26pt below, centered: "Breathe. Ground yourself. Call someone." (system medium 14, `textSecondary`), then 7pt, "No account. Nothing ever leaves this phone." (system regular 12, `textTertiary`). 46pt bottom inset.

The ambient cyan edge glow is deleted.

### 2. Home (`Views/Main/MainView.swift` + the three zone views)

Zone split is unchanged: breath `h/6`, grounding `3h/6`, lifelines `2h/6`.

**Breath band** (`BreathingZoneView`) — `surface` ground, 18pt horizontal inset, 14pt gap, three items in a row:

1. **Wave trough**, 132×104, radius 24, `surfaceRaised`, clipped. Inside it a fill view pinned to the bottom, background = the phase's *soft* color, whose **height animates between 10% and 100%**: to 100% over the inhale duration (linear), holds at 100% through hold-after-inhale, to 10% over the exhale duration, holds at 10% through hold-after-exhale. Holds animate over 0.4s, not instantly. On the top edge of that fill sits a 12pt-tall wave crest — a repeating sine-ish path, 200% width, filled with the phase's *band* color at 55% opacity, drifting horizontally on a 5s linear loop — plus a 2pt solid line of the band color at 80% opacity. The beat number is centered over the whole trough: system light 54, `textPrimary`, monospaced digits.
2. **Text column**: phase label (system bold 11, tracking 3, phase label color) / method name (system semibold 17, `textPrimary`) with a chevron / timing hint, e.g. "4s in · 4s hold · 4s out · 4s hold" (system regular 12, `textTertiary`).
3. **Play–stop button**, 48pt circle, `surfaceRaised` fill, 1pt `borderColor`, glyph in `textPrimary`.

**Grounding zone** (`GroundingMediaView`) — media fills the zone, `.scaledToFill`, with **saturation 0.62 and contrast 0.92** applied, then the `mediaWash` overlay on top. This is the design system's "washed" image treatment and it is what stops the photo shouting over the rest of the screen. A grounding phrase, if set, sits bottom-left at 24pt inset: system regular 23/1.35, `onMedia`, shadow `0 1px 12px rgba(20,16,12,0.55)`. "Take the tour" pill sits top-right, 14pt inset: 7×15 padding, radius 999, `scrim` background, system medium 12, `textSecondary`.

**Lifelines** (`LifelinesZoneView`) — unchanged 2×2 grid, 10pt padding and 10pt gap (was 8). Filled slot: `sageFill` tile, radius 24, 46pt `sageDeep` avatar circle with `sageOn` initials at system bold 17, name below at system semibold 15 in `sageText`. Empty slot: 1.5pt dashed `borderColor`, radius 24, a light "+" at 26pt and a label at system medium 13, both `textTertiary` — "Add someone" and "Make it mine".

**Edge band** (replaces `GlowAnimationView`) — delete all three blurred strokes. In their place: a **7pt solid inset border** in the phase's band color, radius 40, animating its color over 0.5s linear on phase change; plus a **1.5pt inner border** inset 7pt, radius 33, same color at 35% opacity. No blur, no opacity pulsing. This is the single biggest change and the reason the app stops feeling like an alarm.

### 3. Guided tour (`Components/TourOverlayView.swift`)

Same three stops, same zone fractions, same anchoring logic. Changes: the dim bars use `scrimHeavy` instead of black 0.68; the highlight ring is a 2pt `accent` border at 50% opacity with radius 28 (was a 1pt square cyan rect); the card is `surfaceRaised`, radius 28, padding 20/22/18, shadow `0 12px 32px rgba(46,43,37,0.32)`, no border. Step dots are 4pt tall pills, 9pt wide inactive and 24pt wide active, all in `accent` (completed and current both filled). Title moves to Instrument Serif 21; body is system regular 14/1.5 in `textSecondary`; primary button is a 46pt-tall `accent` pill; "Skip" is system medium 14 in `textTertiary`.

Copy for stop 3 is rewritten: **"Four people who will pick up. Put them here once and you can reach them in two taps, without thinking, on the worst night."**

### 4. Settings (`Views/Settings/SettingsView.swift`)

Title "Settings", Instrument Serif 34, 22pt inset, 8pt bottom padding.

A new **APPEARANCE** section comes first: a segmented control — 3 equal columns, 4pt padding, radius 999, `tint` track, selected segment is an `accent` pill with `accentOn` text at system semibold 14, unselected are `textSecondary` at system medium 14. Options **System / Light / Dark**, defaulting to System. Back it with a new `StorageKey.appearance` and apply via `.preferredColorScheme(...)` at the root — remove the hard-coded `.preferredColorScheme(.dark)` from every view.

Then the existing sections, in source order and with source rows: CUSTOMIZE (Customize Breathing, Grounding Media, Customize Lifelines) · REMINDERS (Reminders) · HELP (Guided Tour, Send Feedback + "Feedback is always welcome", Join our Discord + "Community, support and updates") · DATA (Privacy and data, Erase everything).

Row anatomy: 34pt tinted icon circle, 14pt gap, label at system medium 16 in `textPrimary` — **not tinted**; only the destructive row's label takes color. Subtitle at system regular 12 in `textSecondary`. Chevron at the trailing edge in `textTertiary`, omitted on the destructive row. Rows are separated by 1pt `borderColor` rules inside a `surfaceRaised` card, radius 24, 14pt horizontal inset.

The SUPPORT block collapses to one row: `sageFill` card, radius 24, 12×16 padding, "Free, complete and private. Always." at system regular 13 on the left and a `sageDeep` pill button "Leave a tip" (system semibold 13, `sageOn`) on the right.

### 5. Breathing patterns (`Views/Settings/CustomizeBreathingView.swift`)

Each of the four modalities is its own card — `surfaceRaised`, radius 24, 16×18 padding, 10pt apart — with a 1.5pt `accent` border when selected and a transparent border otherwise, so the cards do not shift when selection moves. Header row: name at system semibold 17, and a 22pt circle at the trailing edge, filled `accent` with an `accentOn` check when selected, `tint` and empty when not. Description at system regular 13/1.5 in `textSecondary`.

The beat chips become a **proportional timeline**: a 26pt-tall row of segments, 3pt apart, radius 8, each segment's width weighted by its beat count (`flex: beats`), filled with that phase's *soft* color and labelled with the beat count in its phase *text* color at system semibold 11. 4-7-8 therefore reads as 4-7-8 at a glance.

Descriptions are rewritten and should be used verbatim:
- Box breathing — "Even on all four sides. Steadies the nervous system when everything feels lopsided."
- 4-7-8 — "The long exhale does the work. Fastest route out of a spike."
- Resonant — "A slow, even rhythm. Good for staying calm rather than getting calm."
- Extended exhale — "Twice as long out as in. Simple to follow when you can't concentrate."

Order must follow `BreathingModalities.all`: box, 4-7-8, resonant, extended.

Haptics card below: label at system medium 16, toggle tinted `accent` (54×32 track, 26pt knob), and the note "A soft pulse on every beat, so you can follow the pattern with the phone in your pocket or face-down."

### 6. Grounding anchor (`Views/Settings/GroundingMediaSettingsView.swift`)

Title "Your anchor" plus a subhead: "One thing that pulls you back. A face, a place, or a sentence you need to hear."

Source picker becomes a 4-up segmented control in the same style as Appearance — **Photo / Video / Words / None**. The placement editor keeps its pinch-and-drag behavior; visually it is a `surfaceRaised` card containing a box at the true **390:422** zone aspect ratio, radius 20, showing the washed media under a 1.5pt dashed `onMediaLine` border. Below it, "Reset placement" as plain `accentText` on the left and "Change" as an `accentFill` pill with `accentText` label on the right.

### 7. Lifelines (`Views/Settings/CustomizeLifelinesView.swift`)

**The up/down chevrons are removed. Reordering is press-and-drag.** Use `.onDrag`/`.onDrop` or a `List` with `.onMove`; the dragged row lifts to 45% opacity with a `0 12px 28px rgba(46,43,37,0.3)` shadow and the others reflow live under it.

Each row is its own `surfaceRaised` card, radius 24, 12×14 padding, 10pt apart: a 6-dot grip (two columns of three 4pt dots, 4pt gap, `textTertiary`), 46pt `sageDeep` avatar with `sageOn` initials, name at system semibold 16 over phone at system regular 13 in `textTertiary`, then two 44pt circular buttons — **call** filled `accent` with an `accentOn` glyph, **text** filled `accentFill` with an `accentText` glyph. 44pt is the floor here; these are pressed by someone whose hands are shaking.

"Add a lifeline" is a dashed `borderColor` card, radius 24, centered `accentText` label. Helper copy: "Press and hold a row, then drag it into the order you'd actually reach for. Tap a name to edit, or call and text straight from here."

### 8. Reminders (`Views/Settings/RemindersView.swift`)

Moves off the iOS `List`/`Form` onto the same card language as the rest of the app. Toggle card first — "Daily check-ins", `accent` toggle, and the note "A gentle nudge to breathe before you need to. You choose when, and how often — up to three a day."

Each time is its own `surfaceRaised` card, radius 24, 10pt apart: the time at **system semibold 26 with monospaced digits** in `textPrimary` (tapping opens the wheel), an optional context word like "before work" at system medium 13 in `textTertiary`, and a 38pt `destructiveFill` circle with a `destructive` minus bar to remove it. "Add a time" is the same dashed card as Add a lifeline. Max three, as today.

### 9. Watch (`ride-it-out Watch App/`)

Same tokens, same phase colors. The breathing pane becomes the trough at full-screen scale: the fill rises and drains against `surface`, the crest line drifts across it, the beat sits at system light 58 with the phase label at system bold 10 / tracking 2.6 beneath, and the method name pins to the bottom at system semibold 12. A 5pt solid phase-colored edge band, radius 46, replaces `WatchGlowView`'s blur stack. Grounding pane is the washed image full-bleed. Lifeline pane: 60pt `sageDeep` avatar, name at system semibold 17, and an `accent` "Call" pill — the pane is currently tap-anywhere with a confirmation dialog, which is fine to keep, but the visible button makes the affordance obvious.

---

## Interactions & behavior

- **Breath engine** — unchanged. 1s timer, count down beats, advance phase, wrap. What changes is what the phase drives: band color, trough fill target, trough fill duration, phase label color.
- **Trough fill** — animate `height` linearly over the phase's beat count for inhale and exhale; 0.4s for the two holds. Targets: 100% at the top of the inhale and through hold-after-inhale, 10% at the bottom of the exhale and through hold-after-exhale.
- **Edge band** — animate `color` over 0.5s linear on phase change. No opacity animation at all.
- **Appearance override** — System / Light / Dark, persisted, applied at the root. Every `.preferredColorScheme(.dark)` in the codebase must go.
- **Lifeline drag** — press and hold to lift, drag to reorder, drop to commit; persist order to the keychain as today. Order is the home-screen order.
- **Pattern selection** — unchanged; selecting restarts the engine and persists the id.
- **Buttons** — every interactive element needs a hover/pressed state one step off its base (light: darken toward #B2622D; dark: lighten toward #F6A06B) and a 2pt `accent` focus ring for keyboard/Switch Control. No default system highlight.

## State

No new view-model state beyond:
- `SettingsViewModel.appearance: Appearance` (`.system | .light | .dark`), persisted under a new `StorageKey.appearance`.
- `BreathingViewModel` gains `troughTarget: CGFloat` and `troughDuration: Double` alongside the existing phase state, and its `glowColor`/`glowIntensity` pair collapses to a single `bandColor` (intensity is gone — the band is always solid).
- Lifeline drag state is view-local.

Everything else — modality id, grounding media type/ref/transform, haptics, reminders, lifelines in the keychain — is unchanged.

## Assets

| Asset | Source | Note |
| --- | --- | --- |
| App icon (Default + Dark) | `AppIcon.icon/Assets/` in the repo | **Unchanged.** Ship as-is. A redesigned vector mark appears in the HTML under "The mark" and is explicitly parked — do not implement it. |
| Grounding photo | Organic design system reference image | Placeholder only. The real grounding media is user-supplied. |
| Instrument Serif | Google Fonts, regular 400 | The one new asset. Needed for screen titles and the wordmark. |
| Lucide icons | lucide.dev, stroke-width 2.75 | Optional — see "Icons" above. SF Symbols at semibold is an acceptable substitute. |

## Files in this bundle

| File | What it is |
| --- | --- |
| `Ride It Out - light and dark.dc.html` | The design. Every screen, light and dark side by side, breathing timer live, lifeline drag working. Open in a browser. |
| `Current Build (dark).dc.html` | The existing app rebuilt from the Swift source at its own values, as a before-picture. |
| `github.md` | Repo association and a screen-to-source-file map. |
| `screens/` | One PNG per screen, light beside dark. See `screens/README.md`. |

Both HTML files are self-describing — the prose at the top of each explains what it is showing and why.

## Source map

| Design screen | Swift files to change |
| --- | --- |
| Tokens | `ride-it-out/Constants/Colors.swift`, `ride-it-out Watch App/Colors.swift` |
| Welcome | `Views/Onboarding/WelcomeView.swift` |
| Home | `Views/Main/MainView.swift`, `BreathingZoneView.swift`, `GroundingMediaView.swift`, `LifelinesZoneView.swift`, `Components/LifelineButton.swift`, `Components/GlowAnimationView.swift`, `ViewModels/BreathingViewModel.swift` |
| Guided tour | `Components/TourOverlayView.swift` |
| Settings | `Views/Settings/SettingsView.swift`, `ViewModels/SettingsViewModel.swift`, `Models/Lifeline.swift` (new `StorageKey`) |
| Breathing patterns | `Views/Settings/CustomizeBreathingView.swift` |
| Grounding anchor | `Views/Settings/GroundingMediaSettingsView.swift` |
| Lifelines | `Views/Settings/CustomizeLifelinesView.swift` |
| Reminders | `Views/Settings/RemindersView.swift` |
| Privacy | `Views/Settings/PrivacyView.swift` (tokens only) |
| Watch | `ride-it-out Watch App/` — `BreathingPaneView`, `WatchGlowView`, `GroundingImagePaneView`, `LifelinePaneView` |

## Suggested order

1. `Colors.swift` — both targets, scheme-aware, plus the phase triples. Strip every `.preferredColorScheme(.dark)`.
2. Appearance control in Settings, wired to the root.
3. `GlowAnimationView` → edge band. Biggest visual payoff, smallest diff.
4. `BreathingZoneView` → wave trough.
5. Settings, Breathing, Grounding, Reminders — card language and type.
6. Lifelines drag reorder.
7. Watch.
