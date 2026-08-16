# Fifawy

## 1. Overview

**Fifawy** is a Flutter mobile app designed for FIFA / EA SPORTS FC players who want to quickly generate random teams for 1v1 matches.

The core experience should be extremely simple:

> Open the app → choose optional filters → generate two teams → play.

The app should prioritize **speed, simplicity, usability, and visual polish**.

---

## 2. Core Requirements

### 2.1 Team Data

* The app must use current **EA SPORTS FC 26 team data**.
* Teams must contain, at minimum:

  * Team name
  * Team logo
  * Team type
  * Country
  * League / competition
  * Star rating
* Team types:

  * Club
  * National team
* The team dataset should be structured so that it can easily be updated in the future.
* For the initial version, the dataset can be bundled locally with the application.
* The app should work offline after installation.

### 2.2 Random Match Generation

The main functionality is generating a random 1v1 matchup.

A generated matchup must contain:

* Player 1 team
* Player 2 team

Rules:

* The two generated teams must be different.
* Teams must respect all currently selected filters.
* Each team should have an equal probability of being selected within the filtered pool.
* The user must be able to generate another matchup immediately using a **Reroll / Shuffle** action.
* Generating another matchup should not require reopening the filter interface.

Example:

```text
PLAYER 1

[Team Logo]
Real Madrid


        VS


[Team Logo]
Liverpool

PLAYER 2
```

---

## 3. Filtering System

Users must be able to restrict the pool of teams before generating a matchup.

### 3.1 Team Type

Users can choose:

* All teams
* Clubs only
* National teams only

Default:

* All teams

### 3.2 Competition / League

Users should be able to select a specific league or competition.

Examples:

* Premier League
* La Liga
* Serie A
* Bundesliga
* Ligue 1
* Champions League
* Other supported competitions

The list should be generated from the available team data rather than hardcoded into the UI wherever practical.

### 3.3 Star Rating

Users should be able to filter teams according to their star rating.

Supported ratings:

* 1 star
* 2 stars
* 3 stars
* 4 stars
* 5 stars

The UI should make it easy to select a range when appropriate.

For example:

> 4 ⭐ and above

or:

> 3 ⭐ to 5 ⭐

The exact interaction should remain simple and mobile-friendly.

### 3.4 Combined Filters

Filters must work together.

For example:

```text
Type: Clubs
League: Premier League
Rating: 4+ stars
```

The generated teams must satisfy **all selected conditions**.

Conceptually:

```text
Eligible Teams =
    Teams
    AND selected type
    AND selected competition
    AND selected rating
```

### 3.5 Empty / Invalid Filters

The app must gracefully handle situations where the selected filters produce too few teams.

Examples:

* No teams match the filters.
* Only one team matches the filters.

The application should display a clear message and allow the user to modify the filters.

The app must never crash because of an invalid filter combination.

---

## 4. Filter UX

Filtering should be optimized for mobile devices.

The user should be able to configure a matchup in only a few interactions.

Requirements:

* Filters must be easy to discover.
* Filters should not require navigating through many screens.
* Common options should be accessible immediately.
* Selected filters must be visually obvious.
* Users should be able to quickly remove individual filters.
* A **Reset Filters** action must be available.
* Applying filters should feel instantaneous.
* The interface should avoid unnecessary confirmation dialogs.

The target experience is:

> Open filters → select options → generate matchup

within a few seconds.

---

## 5. Main User Flow

### Default Flow

1. User opens the app.
2. User sees the main matchup screen.
3. User can immediately generate a random matchup.
4. Two teams are displayed.
5. User can:

   * Reroll
   * Open filters
   * Reset filters
6. If filters are active, rerolling must continue using the same filtered pool.

### Example

```text
┌─────────────────────────┐
│       FIFAWY            │
│                         │
│      TEAM A             │
│    [Team Logo]          │
│    Real Madrid          │
│                         │
│         VS              │
│                         │
│    [Team Logo]          │
│      Liverpool          │
│      TEAM B             │
│                         │
│   [ 🔄 REROLL ]         │
│                         │
│   [ ⚙ FILTERS ]         │
└─────────────────────────┘
```

---

## 6. Reroll / Shuffle

The user must be able to generate a new matchup without changing their filters.

Requirements:

* Reroll must be immediately accessible from the result screen.
* The animation should make the change visually satisfying.
* The application should not require a page reload.
* The newly generated matchup must respect the active filters.
* The two teams must be different.

### Optional Future Feature

A **No Rematches** mode could prevent previously generated matchups from appearing again during a session.

This is not required for v1.

---

## 7. Reset Filters

Users must have an easy way to return to the default state.

Resetting filters should restore:

```text
Team type: All
Competition: All
Rating: All
```

After resetting, the next generated matchup should use the complete team dataset.

---

## 8. UI / UX Requirements

The application should have an **elegant, modern, and minimal** design.

The UI should prioritize:

1. Speed
2. Clarity
3. Ease of use
4. Visual polish

### Requirements

* Mobile-first design.
* Responsive layouts.
* Clear visual hierarchy.
* Large, easily tappable controls.
* Minimal unnecessary text.
* Team logos should be prominent.
* Important actions should be immediately visible.
* Avoid excessive menus and navigation.
* Avoid unnecessary screens.

The application should feel like a **quick utility for FIFA players**, not a complex management application.

---

## 9. Animations

The app should use smooth animations and transitions where they improve the experience.

Potential animations:

* Team selection / reveal
* Team logo transitions
* Reroll animation
* Filter panel transitions
* Button interactions
* Screen transitions

Animations must:

* Feel smooth.
* Be short enough to avoid slowing down the user.
* Never prevent the user from quickly generating another matchup.
* Respect reduced-motion accessibility preferences where practical.

The application should prioritize responsiveness over decorative animations.

---

## 10. Team Information

Each generated team should display:

* Team logo
* Team name

Additional information can optionally be displayed:

* Country
* League / competition
* Star rating

The main result screen should remain visually clean.

Detailed team information should not overwhelm the primary matchup experience.

---

## 11. Data Architecture

The initial version should preferably use a local structured dataset.

Example:

```text
assets/
└── data/
    └── teams.json
```

Example team structure:

```json
{
  "id": "real_madrid",
  "name": "Real Madrid",
  "type": "club",
  "country": "Spain",
  "competition": "La Liga",
  "rating": 5,
  "logo": "assets/logos/real_madrid.png"
}
```

The data layer should be separated from the UI and randomization logic so that the team dataset can be updated without restructuring the application.

---

## 12. Randomization Logic

The randomization system must:

* Select only eligible teams.
* Select teams uniformly from the eligible pool.
* Prevent Team A and Team B from being identical.
* Handle small eligible pools safely.
* Avoid crashes when there are insufficient eligible teams.

Conceptually:

```text
All Teams
    ↓
Apply Filters
    ↓
Eligible Teams
    ↓
Randomly Select Team A
    ↓
Randomly Select Team B
    ↓
Display Matchup
```

If the eligible pool contains fewer than two teams, the app must not attempt to generate a matchup.

---

## 13. Offline Requirements

The core functionality should work without an internet connection.

The user should be able to:

* Open the application.
* Apply filters.
* Generate teams.
* Reroll matchups.

No network request should be required for the core random-team functionality.

---

## 14. Error Handling

The application must gracefully handle:

* Empty team datasets.
* Missing team logos.
* Invalid team data.
* Filters producing fewer than two eligible teams.
* Unexpected data parsing errors.

Errors should be communicated to the user clearly without exposing technical details.

---

## 15. Performance

The application should feel instantaneous for normal operations.

Requirements:

* Filtering should be fast.
* Random generation should be effectively instantaneous.
* UI interactions should remain responsive.
* Animations should remain smooth.
* Team logos should be optimized to avoid unnecessary memory usage.
* The application should not perform unnecessary network requests.

The complete process from opening the app to generating a matchup should take **less than one minute**, with the ideal experience being only a few seconds.

---

## 16. Accessibility

The application should consider:

* Sufficient text contrast.
* Large enough touch targets.
* Clear visual feedback for selected filters.
* Meaningful labels for buttons and icons.
* Avoiding color as the only way to communicate state.
* Support for system font scaling where practical.

---

## 17. v1 Scope

### Required

* [ ] Flutter mobile application
* [ ] FC 26 team dataset
* [ ] Club teams
* [ ] National teams
* [ ] Team logos
* [ ] League / competition information
* [ ] Star ratings
* [ ] Random Team A + Team B generation
* [ ] No duplicate team in a matchup
* [ ] Clubs / National / All filter
* [ ] League / competition filter
* [ ] Star-rating filter
* [ ] Combined filters
* [ ] Reset filters
* [ ] Reroll / Shuffle
* [ ] Empty-filter handling
* [ ] Offline functionality
* [ ] Mobile-friendly filter interface
* [ ] Responsive UI
* [ ] Smooth animations and transitions
* [ ] Elegant and minimal design

---

## 18. Potential v2 Features

These should not complicate the initial version.

Possible future features:

* [ ] Match history
* [ ] Favorites
* [ ] No-rematch mode
* [ ] Excluded teams
* [ ] Custom team pools
* [ ] Saved filter presets
* [ ] Team comparison
* [ ] Match statistics
* [ ] Custom game modes
* [ ] Online multiplayer functionality
* [ ] Remote team-data updates
* [ ] Additional FC versions

---

## 19. Core Product Principle

The most important principle of Fifawy is:

> **A player should be able to go from opening the app to getting a playable 1v1 matchup in a few seconds.**

Every feature and UI decision should be evaluated against this principle.

The app should feel:

**Fast → Simple → Fun → Polished**
