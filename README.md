Here is the professional English version of the `README.md` file, perfectly formatted and ready to be published on GitHub:

```markdown
# Prayer Times Plasmoid for KDE Plasma 6

![KDE Plasma 6](https://img.shields.io/badge/KDE-Plasma%206-blue.svg)
![License](https://img.shields.io/badge/License-GPL--3.0+-green.svg)
![Powered by](https://img.shields.io/badge/Powered%20by-PrayTime.js-orange.svg)

A native Plasmoid for the KDE Plasma 6 desktop that displays Islamic prayer times with high accuracy. It works completely offline and supports automatic location detection via system services or manual coordinate input, along with a wide range of globally recognized calculation methods.

## ✨ Features

- **Accurate Offline Calculation**: Powered by the reliable [PrayTime.js](https://praytimes.org/) library for astronomical prayer time calculations.
- **Full Arabic & RTL Support**: User interface fully compatible with Right-to-Left (RTL) layout.
- **Flexible Location Settings**:
  - Automatic detection via system location services (Recommended).
  - Manual coordinate input (Latitude and Longitude) with simplified user tips.
- **Multiple Calculation Methods**: Supports over 12 globally recognized methods including:
  - 🇴🇲 Oman (Official Calendar)
  - Muslim World League (MWL)
  - Islamic Society of North America (ISNA)
  - Egyptian General Authority of Survey
  - Umm Al-Qura University, Makkah
  - University of Islamic Sciences, Karachi
  - Institute of Geophysics, University of Tehran
  - Shia Ithna-Ashari, Leva Institute, Qum (Jafari)
  - France (UOIF), Russia, Malaysia (JAKIM), Singapore (MUIS)
  - Custom Angles
- **Manual Time Adjustments (Offsets)**: Add or subtract minutes from each prayer to match local official calendars.
- **Juristic Methods**: Choice of Asr prayer method (Standard/Shafi, Maliki, Hanbali or Hanafi).
- **Higher Latitudes Support**: Smart solutions for polar regions where twilight persists (Midnight, One-Seventh, or Angle-Based).
- **Multiple Time Formats**: 24-hour, 12-hour with AM/PM, or 12-hour without.
- **Next Prayer Display**: Shows the upcoming prayer name and remaining time directly.
- **Debug Logs**: For developers, displays calculation details and active angles in the terminal.

## 📸 Screenshots

![DeepSeek Timing Plasmoid Preview](screenshots/preview.png)

## 📦 Installation

### Method 1: Using `kpackagetool6` (Recommended)

1. Clone the repository:
   ```bash
   git clone https://github.com/zayedalsaidi/org.kde.prayertimes.git
   cd org.kde.prayertimes
   ```

2. Install the plasmoid to your local Plasma applet directory:
   ```bash
   kpackagetool6 --type=Plasma/Applet --install .
   ```

3. Rebuild the system cache and restart Plasma:
   ```bash
   kbuildsycoca6 --noincremental
   plasmashell --replace &
   ```

### Upgrade the Plasmoid

1. Pull the latest changes from the repository:
   ```bash
   cd org.kde.prayertimes
   git pull
   ```

2. Upgrade the plasmoid:
   ```bash
   kpackagetool6 --type=Plasma/Applet --upgrade .
   ```

3. Rebuild the system cache and restart Plasma:
   ```bash
   kbuildsycoca6 --noincremental
   plasmashell --replace &
   ```

### Method 2: Manual Installation

Copy the `org.kde.prayertimes` folder to:
```bash
~/.local/share/plasma/plasmoids/
```
Then restart Plasma.

## 📂 Project Structure

```text
org.kde.prayertimes/
├── metadata.json              # Plasmoid metadata and version
├── LICENSE                    # GPL-3.0-or-later license
├── README.md                  # This file
└── contents/
    ├── config/
    │   └── main.xml           # KConfig settings definitions
    ├── code/
    │   ├── praytime.js        # PrayTime.js library (modified for QML)
    │   └── prayerEngine.js    # Calculation engine and logic
    └── ui/
        ├── main.qml           # Main plasmoid UI
        └── configGeneral.qml  # Settings UI
```

## ⚙️ Settings

Access settings by right-clicking the plasmoid and selecting "Configure Prayer Times...". Settings are divided into four tabs:

1. **Location**: Adjust coordinates manually or use automatic location.
2. **Appearance**: Choose time display format (24h / 12h).
3. **Calculation**: Calculation method, juristic method, higher latitudes, manual offsets, and custom angles.
4. **About**: Developer info, license, and PrayTime.js links.

## 📚 Acknowledgments

This plasmoid relies on [PrayTime.js](https://praytimes.org/) (v3.2) developed by **Hamid Zarrabi-Zadeh**. The library has been slightly modified to ensure full compatibility with the Qt/QML environment in KDE Plasma 6.

- **Official Website**: https://praytimes.org/
- **Calculation Documentation**: https://praytimes.org/docs/calculation
- **Source Code**: https://github.com/zarrabi/praytime
- **License**: MIT License

## 🌐 Translation

All UI texts are wrapped in `i18n()` to support multi-language translations. To contribute, please create `.po` files in the `po/` directory following KDE standards.

## 🐛 Bug Reports

If you encounter any issues or have suggestions for improvement, please open an Issue on [GitHub](https://github.com/zayedalsaidi/org.kde.prayertimes/issues).

## 📄 License

Distributed under the **GPL-3.0-or-later** License. See `LICENSE` for more details.

---

Made with ❤️ for the KDE community and Muslim users worldwide.
```
