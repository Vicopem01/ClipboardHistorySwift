import Cocoa
//import MASShortcut

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize managers
        _ = ClipboardHistoryManager.shared
        _ = GlobalShortcutHandler.shared
    }
}

