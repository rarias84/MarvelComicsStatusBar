import Foundation
import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = StatusBarController()
        controller.setup()
        self.statusBarController = controller
    }
}
