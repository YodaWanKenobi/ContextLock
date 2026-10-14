import SwiftUI

@main
struct ContextLockApp: App {
    @StateObject private var viewModel = ContextViewModel()
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("ContextLock", systemImage: "brain.head.profile") {
            ContentView()
                .environmentObject(viewModel)
                .frame(width: 340, height: 420)
                .background(PanelHotKeyBinder())
        }
        .menuBarExtraStyle(.window)

        Window("ContextLock", id: "context-panel") {
            ContentView()
                .environmentObject(viewModel)
                .frame(width: 340, height: 420)
                .background(PanelHotKeyBinder())
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 340, height: 420)
        .handlesExternalEvents(matching: Set(arrayLiteral: "panel"))
        #else
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        #endif
    }
}
