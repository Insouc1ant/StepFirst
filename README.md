# 👟 StepFirst — Steps to Unlock

<p align="center">
  <strong>Turn your daily physical activity into your digital allowance.</strong><br>
  <em>Walk to unlock your most distracting apps.</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 17.0+">
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.0">
  <img src="https://img.shields.io/badge/Xcode-16.0+-1575F9?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode 16.0+">
  <img src="https://img.shields.io/badge/Architecture-MVVM-6366F1?style=for-the-badge" alt="MVVM">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="MIT License">
</p>

---

## 📖 Overview

**StepFirst** is an iOS digital wellness and habit-building app that transforms physical movement into earned screen time. Instead of relying purely on willpower or strict hard limits, StepFirst locks your chosen distracting apps (social media, games, video streaming) and requires you to walk a target number of steps before temporarily unlocking them.

Powered by Apple's **Screen Time API** (`FamilyControls`, `ManagedSettings`, `DeviceActivity`) and **CoreMotion** (`CMPedometer`), StepFirst provides a seamless, privacy-first experience running entirely on-device with zero external servers.

---

## ✨ Key Features

- 🔒 **Native App Shielding**: Restrict entire categories or individual apps directly using Apple's official `FamilyControls` picker.
- 🚶‍♂️ **Step-Powered Unlocks**: Set your step target (e.g., 50 to 2,000 steps). Complete your walking goal to unlock restricted apps.
- ⏱️ **Earned Allowance Duration**: Configure how much screen time you earn per completed goal (e.g., 15 mins, 30 mins, 1 hour). When your allowance timer reaches zero, apps automatically re-lock.
- 🛡️ **Custom SpringBoard Shield**: When an app is locked, a native iOS system shield intercepts the launch with your app's branding, current step goal, and quick actions ("Check Steps & Unlock" or "Continue Walking").
- 📊 **Real-Time Dashboard & Ring Progress**: Clean 280pt hero progress ring tracking steps walked, active allowance countdown, and restricted app quick-views.
- 🎨 **Strict Apple HIG Dynamic Type**: 100% compliant with Apple Human Interface Guidelines typography, scaling seamlessly with system text size settings.
- 🛡️ **Privacy-First & On-Device**: Zero trackers, zero analytics servers. Step counting and app tokens are handled locally using sandboxed iOS system frameworks.

---


### Target Responsibilities:

1. **StepFirst (Main App)**: User interface, onboarding flow, step-goal customization, allowance timers, and live `CMPedometer` tracking.
2. **AppMonitorExtension (`DeviceActivityMonitor`)**: Monitors device activity intervals in the background to handle allowance countdowns and trigger locks even when the app is terminated.
3. **AppShieldConfig (`ShieldConfigurationDataSource`)**: Configures the appearance of Apple's SpringBoard shield (app icon squircle, title, customized goal copy, and adaptive button labels).
4. **AppShieldAction (`ShieldActionDelegate`)**: Intercepts button taps directly on the system shield ("Check Steps & Unlock" opens StepFirst via deep link; "Continue Walking" closes the app).
5. **AppUsageReport (`DeviceActivityReport`)**: Sandboxed extension for rendering privacy-preserving app usage statistics.

---

## 🛠️ Tech Stack & Frameworks

| Layer | Frameworks / Technologies |
| :--- | :--- |
| **UI & Layout** | SwiftUI, SF Symbols, Apple HIG Dynamic Type |
| **Screen Time & Blocking** | `FamilyControls`, `ManagedSettings`, `ManagedSettingsUI`, `DeviceActivity` |
| **Motion & Activity** | `CoreMotion` (`CMPedometer`) |
| **Notifications** | `UserNotifications` (`UNUserNotificationCenter`) |
| **Persistence** | `UserDefaults` (App Group suite), `SwiftData` |
| **Design System** | Indigo Brand Palette, Native Squircles (22.4% curvature), Semantic Dynamic Colors |

---

## 📂 Project Structure

```text
StepFirst/
├── StepFirst/
│   ├── StepFirst.swift              # Application entrypoint & App Group synchronization
│   ├── Views/
│   │   ├── Dashboard/
│   │   │   ├── DashboardView.swift  # Hero progress ring, active timer & stats
│   │   │   └── SettingsView.swift   # Step goal slider, duration picker & selection list
│   │   └── Onboarding/
│   │       ├── LockedAppsView.swift # App restriction selection intro
│   │       └── SetPlanView.swift    # Step goal & allowance initial setup
│   ├── ViewModels/
│   │   ├── DashboardViewModel.swift # State machine for steps, timers & allowance
│   │   ├── SettingsViewModel.swift  # Settings persistence & notice handling
│   │   └── OnboardingViewModel.swift# Onboarding flow state management
│   ├── Components/
│   │   ├── HeroProgressRing.swift   # 280pt circular progress indicator
│   │   ├── StatCard.swift           # Modular card component
│   │   ├── StatusIndicator.swift    # Apps Locked / Apps Available status badge
│   │   ├── SectionHeader.swift      # Form & dashboard section headers
│   │   └── ScaledIconLabelStyle.swift # Custom LabelStyle for FamilyControls tokens
│   ├── Services/
│   │   ├── StepManager.swift        # CoreMotion live pedometer tracker
│   │   ├── ScreenTimeManager.swift  # ManagedSettingsStore shield coordinator
│   │   ├── DeviceActivityManager.swift # DeviceActivity schedule coordinator
│   │   └── NotificationManager.swift# System push notifications
│   └── Utilities/
│       ├── Font+App.swift           # Native Apple HIG Dynamic Type tokens
│       └── StorageKeys.swift        # App Group shared keys & constants
└── Extensions/
    ├── AppMonitorExtension/         # Background DeviceActivity schedule monitoring
    ├── AppShieldConfig/             # SpringBoard custom shield configuration
    ├── AppShieldAction/             # Interactive shield button actions
    └── AppUsageReport/              # DeviceActivity usage report views
```

---

## 🚀 Getting Started

### Prerequisites
- macOS Sonoma (14.0+) or macOS Sequoia (15.0+)
- Xcode 16.0 or later
- An active **Apple Developer Account** (Required for the `Family Controls (Development)` entitlement)
- Physical iOS Device with **iOS 17.0+** *(FamilyControls shield extensions require testing on a physical iPhone)*

### Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/StepFirst.git
   cd StepFirst
   ```

2. **Open the project in Xcode**:
   ```bash
   open StepFirst.xcodeproj
   ```

3. **Configure Signing & Capabilities**:
   - Select the `StepFirst` project in the project navigator.
   - For **each** of the 5 targets (`StepFirst`, `AppMonitorExtension`, `AppShieldConfig`, `AppShieldAction`, `AppUsageReport`):
     - In **Signing & Capabilities**, select your personal or team Apple Developer account.
     - Verify that **App Groups** is enabled with `group.com.kee.StepFirst` (or your team's custom bundle identifier).
     - Verify that **Family Controls** is checked.

4. **Build and Run**:
   - Connect your physical iOS device.
   - Select the `StepFirst` target and your device.
   - Press **Run** (`Cmd + R`).
   - When prompted on first launch, grant **Screen Time** and **Motion & Fitness** permissions.

---

## 🔒 Privacy by Design

StepFirst strictly follows Apple's privacy-by-design guidelines:
- **Zero Data Collection**: No user step counts, location, or app usage data is ever collected, transmitted, or stored off-device.
- **Out-of-Process Token Isolation**: By using Apple's `ApplicationToken` and `ActivityCategoryToken`, StepFirst **never knows** which specific apps you choose to lock. The tokens are opaque representations resolved exclusively by iOS system services.

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
