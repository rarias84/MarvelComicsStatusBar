import AppKit
import SwiftUI

@MainActor
final class StatusBarController: NSObject, ObservableObject {
    private var statusItem: NSStatusItem!
    private let popover = NSPopover()
    private let menu = NSMenu()
    private var listViewModel: ComicsListViewModel?
    private var eventMonitor: Any?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let btn = statusItem.button {
            btn.image = NSImage(systemSymbolName: "books.vertical", accessibilityDescription: "Comics")
            btn.action = #selector(togglePopover(_:))
            btn.target = self
            btn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let vm = ComicsListViewModel(client: MarvelClient.live())
        self.listViewModel = vm
        let root = ComicsListView(viewModel: vm)
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 520, height: 560)
        popover.contentViewController = NSHostingController(rootView: root)

        let reloadItem = NSMenuItem(title: "Recargar", action: #selector(reload), keyEquivalent: "r")
        reloadItem.target = self
        let quitItem = NSMenuItem(title: "Salir", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.items = [reloadItem, .separator(), quitItem]
    }

    @objc private func togglePopover(_ sender: Any?) {
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            if let button = statusItem.button {
                statusItem.menu = menu
                button.performClick(nil)
                statusItem.menu = nil
            }
            return
        }

        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }

    private func showPopover(_ sender: Any?) {
        guard let button = statusItem.button else {
            return
        }
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self else {
                return event
            }
            if self.popover.isShown {
                guard let window = self.popover.contentViewController?.view.window, window.frame.contains(NSEvent.mouseLocation) else {
                    self.closePopover(nil)
                    return event
                }
            }
            return event
        }
    }

    private func closePopover(_ sender: Any?) {
        popover.performClose(sender)
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }

    deinit { }

    @objc private func reload() {
        guard let vm = listViewModel else {
            let vm = ComicsListViewModel(client: MarvelClient.live())
            self.listViewModel = vm
            if let hosting = popover.contentViewController as? NSHostingController<ComicsListView> {
                hosting.rootView = ComicsListView(viewModel: vm)
            } else {
                popover.contentViewController = NSHostingController(rootView: ComicsListView(viewModel: vm))
            }
            vm.resetNavigationFlag = true
            Task {
                await vm.load()
            }
            return
        }
        vm.resetNavigationFlag = true
        Task {
            await vm.load()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
