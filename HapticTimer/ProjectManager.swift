import Foundation

struct Project: Identifiable, Codable {
    var id = UUID()
    var name: String
    var isActive: Bool = false
    var trackedSeconds: Int = 0
    var targetSeconds: Int? = nil
}

class ProjectManager: ObservableObject {
    static let shared = ProjectManager()

    @Published var projects: [Project] = []
    @Published var currentProjectID: UUID?

    private var timer: Timer?

    init() {
        loadProjects()
    }

    func startTracking(projectID: UUID) {
        stopTracking()
        currentProjectID = projectID
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let index = self.projects.firstIndex(where: { $0.id == projectID }) else { return }
            self.projects[index].trackedSeconds += 1
            self.saveProjects()
        }
    }

    func stopTracking() {
        timer?.invalidate()
        timer = nil
        currentProjectID = nil
    }

    func addProject(name: String) {
        let newProject = Project(name: name)
        projects.append(newProject)
        saveProjects()
    }

    func deleteProject(id: UUID) {
        if currentProjectID == id {
            stopTracking()
        }
        projects.removeAll { $0.id == id }
        saveProjects()
    }

    private func saveProjects() {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: "projects")
        }
    }

    private func loadProjects() {
        if let data = UserDefaults.standard.data(forKey: "projects"),
           let saved = try? JSONDecoder().decode([Project].self, from: data) {
            self.projects = saved
        }
    }
}
