# **Fifawy**

**Fifawy** is a sleek, modern Flutter application built for EA SPORTS FC 26 players to quickly generate fair, customizable, and random 1v1 matchups for competitive kick-off and couch gaming sessions.

---

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center" width="20%">
        <b>1. Splash / Loading Screen</b><br/><br/>
        <img src="screenshots/IMG_20260818_124653.jpg" alt="Splash & Loading Screen" width="100%"/>
      </td>
      <td align="center" width="20%">
        <b>2. Main Screen</b><br/><br/>
        <img src="screenshots/Screenshot_2026_08_18_12_44_21_46_1ca03f406ff0432d7b7a5c906f3cc311.jpg" alt="Main Screen" width="100%"/>
      </td>
      <td align="center" width="20%">
        <b>3. Filter Bottom Sheet</b><br/><br/>
        <img src="screenshots/Screenshot_2026_08_18_12_44_47_94_1ca03f406ff0432d7b7a5c906f3cc311.jpg" alt="Filter Bottom Sheet" width="100%"/>
      </td>
      <td align="center" width="20%">
        <b>4. Matchup Result</b><br/><br/>
        <img src="screenshots/Screenshot_2026_08_18_12_45_24_55_1ca03f406ff0432d7b7a5c906f3cc311.jpg" alt="Matchup Result" width="100%"/>
      </td>
      <td align="center" width="20%">
        <b>5. App Information</b><br/><br/>
        <img src="screenshots/Screenshot_2026_08_18_12_46_12_79_1ca03f406ff0432d7b7a5c906f3cc311.jpg" alt="App Info Dialog" width="100%"/>
      </td>
    </tr>
  </table>
</div>

---

## ⚽ Features & How It Works

- **Instant 1v1 Matchup Generation**: With a single tap, generate a balanced home vs. away match without endless scrolling through team selection menus.
- **One-Tap Quick Play Presets**:
  - **All Teams**: Pick randomly from the full catalog of available teams.
  - **Clubs Only**: Limits the pool strictly to club teams.
  - **National Teams**: Generates matchups exclusively between national squads.
  - **4★+ Clubs**: Automatically filters for top-tier competitive club matchups.
- **Deep Filtering Controls**:
  - Filter by **Team Type** (Clubs, National Teams, or All).
  - Filter by **League / Competition** with integrated search and quick chips (Premier League, La Liga, Champions League, FIFA World Cup, Serie A, Bundesliga, etc.).
  - Filter by **Star Rating** (e.g. 3.5★, 4★, 4.5★, 5★).
  - Live preview badge displaying eligible teams count before applying.
- **Dynamic Matchup Screen**:
  - Displays high-resolution team logos, official club names, star ratings, league tags, and home/away badges.
  - **Reroll**: Spin again instantly with the active filter parameters.
  - **Quick Adjust**: Modify filters directly from the matchup screen.
- **App Info & Statistics**: Tap the info icon in the top bar to view total loaded teams, competitions count, and version info.

---

## 🛠️ Technical Details & Data Architecture

- **Framework**: Built with **Flutter 3.x** and **Dart 3.x** using Material 3 design principles.
- **Offline-First Storage**:
  - Bundled with a comprehensive local dataset (`data/teams_offline.json`) containing **450+ teams** and **30+ competitions**.
  - Fully functional with zero internet connection required.
- **Assets & Media**:
  - High-performance asset loading for SVG and PNG club crests (`data/logos/`).
  - Seamless loop background video player (`video_player`) powering the dynamic football pitch animation on the home screen.
- **Theme & Design System**:
  - Immersive dark UI styled with an EA FC neon-green accent aesthetic (`AppColors.accentGreen` `#38EF58`, background `#070706`).
  - Modern typography using `google_fonts` (**Outfit**).
  - Native adaptive launch splash integration configured across both legacy and Android 12+ Splash APIs.
- **Matching Algorithm**:
  - Fast O(N) pool filtering with constraint verification (ensures distinct home and away teams and prevents immediate consecutive duplicate matchups).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13.0 or higher)
- Android Studio / VS Code with Flutter extension
- Connected Android device or Emulator

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/fifawy.git
   cd fifawy
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```
