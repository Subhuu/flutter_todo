# � Project Devlog: Glass Todo App

**Date:** Jan 23, 2026

## 🌟 The Vision
The goal was simple but ambitious: move away from boring, flat list apps and build something that actually looks *good*. We went with a **Glassmorphism** aesthetic—frosted glass cards, colorful gradients, and smooth interactions. It’s not just about tracking tasks; it’s about enjoying the UI while doing it.

---

## 🏗️ What I Built
We started from scratch with Flutter and built a robust Todo application. Here are the highlights:

*   **Glass UI**: Custom `GlassContainer` widgets everywhere. No default Material cards here.
*   **Smart Persistence**: Hooked up `SharedPreferences` so data survives app restarts. It feels like a proper offline-first app now.
*   **Recurring Tasks**: Added logic to handle Daily, Weekly, and Monthly tasks. When you check one off, the next one is automatically scheduled.
*   **Stats Dashboard**: A cool graphical view (Bar charts + Progress rings) to visualize productivity over the last week.
*   **User Profile**: A dedicated profile section where I can set my details. I even added a constraint so I can't spam-update my profile—updates are locked for 30 days.

---

## 🔧 The Challenges (and How I Fixed Them)

### 1. The "Offline" Scare
At first, everything vanished when I closed the app.
*   **Fix**: Implemented a Service layer pattern (`TodoService`) that saves to local storage on every single modification. Now it remembers everything.

### 2. Flutter Deprecations
Flutter 3.x threw some curveballs. `Color.withOpacity` and the old Dropdown widgets were causing warnings.
*   **Fix**: Updated everything to use the modern `withValues(alpha: ...)` API and refactored the dropdowns to use `InputDecorator` for a cleaner, warning-free codebase.

### 3. The Emulator Struggle
Manually selecting the device every time `F5` was pressed got annoying fast.
*   **Fix**: I configured VS Code (`launch.json` & `tasks.json`) to automatically boot up the specific AVD (`Medium_Phone_API_36.1`) and attach the debugger in one go. Smooth sailing now.

### 4. UI Polish
The initial input area was too cluttered.
*   **Fix**: Redesigned it to be compact. Moved the recurring options into a neat dropdown icon and turned the static user avatar into a functional navigation button.

---

## 🚀 What's Next?
The app is solid now (v1.0.0 released!), but there's always room for more:
*   Maybe cloud sync with Firebase?
*   Push notifications for those daily tasks?
*   Dark/Light mode toggle?

---
*Built with ❤️ and Dart.*
