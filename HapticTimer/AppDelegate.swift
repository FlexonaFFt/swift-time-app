import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    let scenarioManager = ScenarioManager.shared
    var scenarioWindow: NewScenarioWindowController?
    
    @objc func showInsights() {
        // Пока ничего не делаем
        print("Insights clicked")
    }

    @objc func toggleLaunchAtStartup() {
        // Заглушка: автозапуск пока не реализован
        print("Launch at startup toggled")
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "Haptic Timer"
        alert.informativeText = "Версия 1.0\nАвтор: Ты :)"
        alert.runModal()
    }

    var isLoginItem: Bool {
        // Пока всегда false, позже добавим проверку launchd
        return false
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создание иконки в строке меню
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        updateStatusTitle()

        // Обновление отображения каждую секунду
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.updateStatusTitle()
            self.updateMenu()
        }

        updateMenu()
    }

    func updateStatusTitle() {
        if let scenario = scenarioManager.activeScenario {
            let h = scenarioManager.remainingSeconds / 3600
            let m = (scenarioManager.remainingSeconds % 3600) / 60
            let s = scenarioManager.remainingSeconds % 60
            statusItem?.button?.title = String(format: "⏱ %d:%02d:%02d", h, m, s)
        } else {
            statusItem?.button?.title = "⏱"
        }
    }

    func updateMenu() {
        let menu = NSMenu()

        if !scenarioManager.scenarios.isEmpty {
            for scenario in scenarioManager.scenarios {
                let isRunning = scenarioManager.activeScenario?.id == scenario.id
                let title = scenario.name + (isRunning ? " ⏸" : "")
                let item = NSMenuItem(title: title, action: #selector(toggleScenario(_:)), keyEquivalent: "")
                item.representedObject = scenario.id
                menu.addItem(item)
            }
            menu.addItem(NSMenuItem.separator())
        }

        // Новый проект
        let newItem = NSMenuItem(title: "New project", action: #selector(openScenarioWindow), keyEquivalent: "n")
        newItem.image = NSImage(systemSymbolName: "plus", accessibilityDescription: nil)
        menu.addItem(newItem)

        // Insights (заглушка)
        let insightsItem = NSMenuItem(title: "Insights", action: #selector(showInsights), keyEquivalent: "")
        insightsItem.image = NSImage(systemSymbolName: "chart.bar", accessibilityDescription: nil)
        menu.addItem(insightsItem)

        // Open App (заглушка)
        let openAppItem = NSMenuItem(title: "Open app", action: #selector(openScenarioWindow), keyEquivalent: "")
        openAppItem.image = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: nil)
        menu.addItem(openAppItem)

        menu.addItem(NSMenuItem.separator())

        // Автозапуск
        let launchItem = NSMenuItem(title: "Launch at startup", action: #selector(toggleLaunchAtStartup), keyEquivalent: "")
        launchItem.state = isLoginItem ? .on : .off
        launchItem.image = NSImage(systemSymbolName: "checkmark.circle", accessibilityDescription: nil)
        menu.addItem(launchItem)

        menu.addItem(NSMenuItem.separator())

        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func toggleScenario(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? UUID else { return }
        if scenarioManager.activeScenario?.id == id {
            scenarioManager.stop()
        } else if let scenario = scenarioManager.scenarios.first(where: { $0.id == id }) {
            scenarioManager.start(scenario: scenario)
        }
        updateMenu()
    }

    @objc func stopScenario() {
        scenarioManager.stop()
        updateMenu()
    }

    @objc func openScenarioWindow() {
        scenarioWindow = NewScenarioWindowController()
        scenarioWindow?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
