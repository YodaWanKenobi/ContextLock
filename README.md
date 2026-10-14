# ContextLock

Native SwiftUI multiplatform app that freezes your current train of thought before you switch tabs, leave the desk, or pick up your phone. macOS lives in the menu bar. iOS keeps the same lock on-device and on the Home Screen.

## Why it exists

Context switching is cheap. Getting the original thought back is not. ContextLock is a one-field intercept: type the thought, lock it, restore it later from the Mac status item, an iPhone screen, or a live widget.

## Architecture

| File | Target | Responsibility |
| --- | --- | --- |
| `ContextLockApp.swift` | macOS / iOS | Menu bar extra + hotkey window on Mac; native window on iOS |
| `ContextModel.swift` | Shared | `ContextSnapshot` (text, timestamp, active flag) |
| `ContextViewModel.swift` | Shared | Input, persistence, widget timeline reload |
| `AppGroupStore.swift` | App + Widget | App Group `UserDefaults` so the widget can read the same lock |
| `ContentView.swift` | Shared UI | OLED terminal layout: standby intercept vs locked memory |
| `GlobalHotKeyMonitor.swift` | macOS | Global **⌃⌥L** (Control + Option + L) via Carbon hotkey |
| `ContextLockWidget.swift` | iOS widget | Home Screen + Lock Screen glance of the locked thought |

```
iOS App  ──┐
macOS App ─┼── App Group (group.app.contextlock.ContextLock) ── iOS Widget
           └── UserDefaults snapshot + reset count
```

## Requirements

- Xcode 16+
- iOS 17+ / macOS 14+
- Apple ID team selected in Signing & Capabilities (needed for App Groups and running on device)

## Run it

1. Open `ContextLock.xcodeproj` in Xcode.
2. Select the **ContextLock** scheme.
3. Set your **Team** on both the `ContextLock` and `ContextLockWidget` targets.
4. Confirm App Group `group.app.contextlock.ContextLock` is enabled on both targets (Signing & Capabilities → App Groups).
5. Run.

### macOS

- Status item: brain icon in the menu bar. Click to lock or restore.
- Global shortcut: **Control + Option + L** opens the compact recall window from any app. Carbon hotkeys do not need Accessibility permission.
- `LSUIElement` is on, so there is no Dock icon.

### iOS

- Main screen matches the menu bar UI.
- After the first run: long-press the Home Screen → **Add Widget** → **ContextLock**.
- Families: small, medium, and Lock Screen rectangular.
- Locking or restoring in the app reloads the widget timeline immediately.

## Data

Snapshots are local only. The active thought is a `Codable` blob in the App Group suite (`ContextLock_ActiveCache`). Restore count lives under `ContextLock_TotalCount`. Nothing leaves the device.

## Product notes for submissions

- **Native, not a wrapped web view.** One SwiftUI codebase, two platform shells.
- **WidgetKit + App Groups** is a concrete iOS systems skill, not a tutorial clone of a to-do list.
- **MenuBarExtra + global hotkey** is a concrete macOS skill recruiters recognize from shipping utility apps.
- Keep the README honest: this is a focused utility, not a social network.

## Next ideas (not built)

- User-configurable shortcut
- iCloud of the latest lock
- Lock Screen widget deep link back into the app
- Export a short “context log” of restored thoughts
