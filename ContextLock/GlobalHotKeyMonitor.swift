#if os(macOS)
import AppKit
import Carbon
import Foundation
import SwiftUI

extension Notification.Name {
    static let contextLockTogglePanel = Notification.Name("ContextLock.togglePanel")
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        GlobalHotKeyMonitor.shared.register {
            NSApp.activate(ignoringOtherApps: true)
            if let url = URL(string: "contextlock://panel") {
                NSWorkspace.shared.open(url)
            }
            NotificationCenter.default.post(name: .contextLockTogglePanel, object: nil)
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        GlobalHotKeyMonitor.shared.unregister()
    }
}

final class GlobalHotKeyMonitor {
    static let shared = GlobalHotKeyMonitor()
    static let signature: OSType = 0x434C4B31 // 'CLK1'
    static let hotKeyIDValue: UInt32 = 1

    /// Control + Option + L
    static let displayChord = "⌃⌥L"

    private var hotKeyRef: EventHotKeyRef? = nil
    private var handlerRef: EventHandlerRef? = nil
    private var onPressed: (() -> Void)? = nil

    private init() {}

    func register(onPressed: @escaping () -> Void) {
        unregister()
        self.onPressed = onPressed

        var hotKeyID = EventHotKeyID(signature: Self.signature, id: Self.hotKeyIDValue)
        let modifiers = UInt32(controlKey | optionKey)
        let keyCode = UInt32(kVK_ANSI_L)
        var newHotKeyRef: EventHotKeyRef? = nil
        RegisterEventHotKey(keyCode, modifiers, hotKeyID, GetApplicationEventTarget(), 0, &newHotKeyRef)
        hotKeyRef = newHotKeyRef

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let userData = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        InstallEventHandler(
            GetApplicationEventTarget(),
            contextLockHotKeyHandler,
            1,
            &eventType,
            userData,
            &handlerRef
        )
    }

    func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let handlerRef {
            RemoveEventHandler(handlerRef)
            self.handlerRef = nil
        }
        onPressed = nil
    }

    fileprivate func handlePress() {
        onPressed?()
    }
}

private func contextLockHotKeyHandler(
    _ nextHandler: EventHandlerCallRef?,
    _ event: EventRef?,
    _ userData: UnsafeMutableRawPointer?
) -> OSStatus {
    guard let userData, let event else { return OSStatus(eventNotHandledErr) }

    var hotKeyID = EventHotKeyID()
    let status = GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    guard status == noErr, hotKeyID.signature == GlobalHotKeyMonitor.signature else {
        return OSStatus(eventNotHandledErr)
    }

    let monitor = Unmanaged<GlobalHotKeyMonitor>.fromOpaque(userData).takeUnretainedValue()
    DispatchQueue.main.async {
        monitor.handlePress()
    }
    return noErr
}

struct PanelHotKeyBinder: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .accessibilityHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .contextLockTogglePanel)) { _ in
                openWindow(id: "context-panel")
            }
    }
}
#endif
