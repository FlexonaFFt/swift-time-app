import Foundation
import Cocoa
import UserNotifications

struct Scenario: Identifiable, Codable {
    var id = UUID()
    var name: String
    var durationSeconds: Int
}

class ScenarioManager: ObservableObject {
    static let shared = ScenarioManager()

    @Published var scenarios: [Scenario] = []
    @Published var activeScenario: Scenario?
    @Published var remainingSeconds: Int = 0

    var timer: Timer?

    init() {
        load()
    }

    func start(scenario: Scenario) {
        stop()
        activeScenario = scenario
        remainingSeconds = scenario.durationSeconds

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.remainingSeconds -= 1
            if self.remainingSeconds <= 0 {
                self.notify()
                self.stop()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        activeScenario = nil
        remainingSeconds = 0
    }

    func add(name: String, durationMinutes: Int) {
        let s = Scenario(name: name, durationSeconds: durationMinutes * 60)
        scenarios.append(s)
        save()
    }

    func notify() {
        let content = UNMutableNotificationContent()
        content.title = "Сценарий завершён"
        content.body = activeScenario?.name ?? ""
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func save() {
        if let data = try? JSONEncoder().encode(scenarios) {
            UserDefaults.standard.set(data, forKey: "scenarios")
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: "scenarios"),
           let decoded = try? JSONDecoder().decode([Scenario].self, from: data) {
            self.scenarios = decoded
        }
    }
}
