import Cocoa
import EventKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    let eventStore = EKEventStore()
    var timer: Timer?
    var remainingSeconds: Int = 0
    var activeEvent: EKEvent?

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestCalendarAccess()
        setupStatusItem()
    }

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "⏱ --:--"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh Now", action: #selector(refreshEvent), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    func requestCalendarAccess() {
        eventStore.requestFullAccessToEvents { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.refreshEvent()
                }
            } else {
                print("Access denied to calendar: \(error?.localizedDescription ?? "No reason")")
            }
        }
    }

    @objc func refreshEvent() {
        timer?.invalidate()
        activeEvent = getCurrentEvent()

        if let event = activeEvent {
            remainingSeconds = Int(event.endDate.timeIntervalSinceNow)
            startCountdown()
        } else {
            statusItem?.button?.title = "⏱ No event"
        }
    }

    func getCurrentEvent() -> EKEvent? {
        let calendars = eventStore.calendars(for: .event)
        let now = Date()
        let end = now.addingTimeInterval(3600 * 4)
        let predicate = eventStore.predicateForEvents(withStart: now, end: end, calendars: calendars)
        let events = eventStore.events(matching: predicate)

        return events.first(where: { $0.startDate <= now && $0.endDate >= now })
    }

    func startCountdown() {
        updateStatusTitle()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                self.statusItem?.button?.title = "⏱ Done"
                self.timer?.invalidate()
            } else {
                self.updateStatusTitle()
            }
        }
    }

    func updateStatusTitle() {
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        statusItem?.button?.title = String(format: "⏱ %02d:%02d:%02d", h, m, s)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
