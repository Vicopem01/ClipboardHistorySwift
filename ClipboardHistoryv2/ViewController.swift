import Cocoa
import AppKit

class ClipboardHistoryManager {
    static let shared = ClipboardHistoryManager()
    private var clipboardHistory: [String] = []
    private let maxItems = 10
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let pasteboard = NSPasteboard.general.string(forType: .string) else { return }
            self?.addToHistory(pasteboard)
        }
    }
    
    private func addToHistory(_ item: String) {
        if !clipboardHistory.contains(item) {
            clipboardHistory.insert(item, at: 0)
            if clipboardHistory.count > self.maxItems {
                clipboardHistory.removeLast()
            }
        }
    }
    
    func getHistory() -> [String] {
        return clipboardHistory
    }
}

class GlobalShortcutHandler {
    static let shared = GlobalShortcutHandler()
    
    private init() {
        setupEventMonitor()
    }
    
    private func setupEventMonitor() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check for CMD + .
            if event.modifierFlags.contains(.command) && event.keyCode == 47 {
                self?.showClipboardHistory()
            }
        }
    }
    
    // Change this to internal (default) access level
    func showClipboardHistory() {
        let history = ClipboardHistoryManager.shared.getHistory()
        
        let historyWindow = NSWindow(
            contentRect: NSRect(x: 100, y: 100, width: 300, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let scrollView = NSScrollView(frame: historyWindow.contentView!.bounds)
        let textView = NSTextView(frame: scrollView.bounds)
        textView.string = history.joined(separator: "\n")
        textView.isEditable = false
        
        scrollView.documentView = textView
        historyWindow.contentView?.addSubview(scrollView)
        
        historyWindow.makeKeyAndOrderFront(nil)
    }
}

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let historyButton = NSButton(title: "Show Clipboard History", target: self, action: #selector(showHistory))
        historyButton.frame = CGRect(x: 20, y: 20, width: 200, height: 40)
        view.addSubview(historyButton)
    }
    
    @objc func showHistory() {
        GlobalShortcutHandler.shared.showClipboardHistory()
    }
}


