import Cocoa

class NewScenarioWindowController: NSWindowController {

    let nameField = NSTextField()
    let timeField = NSTextField()

    init() {
        // Обычное окно macOS со всеми элементами управления
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 200),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )

        window.title = "New Scenario"
        window.isReleasedWhenClosed = false
        window.center()

        super.init(window: window)
        setupContent(in: window.contentView!)
    }

    private func setupContent(in contentView: NSView) {
        // Метки
        let nameLabel = NSTextField(labelWithString: "Scenario name:")
        nameLabel.font = .systemFont(ofSize: 13)

        let timeLabel = NSTextField(labelWithString: "Duration (min):")
        timeLabel.font = .systemFont(ofSize: 13)

        // Поля ввода
        nameField.placeholderString = "e.g. Smart home project"
        nameField.bezelStyle = .roundedBezel
        nameField.translatesAutoresizingMaskIntoConstraints = false

        timeField.placeholderString = "e.g. 25"
        timeField.bezelStyle = .roundedBezel
        timeField.translatesAutoresizingMaskIntoConstraints = false

        // Кнопка
        let createButton = NSButton(title: "Create", target: self, action: #selector(create))
        createButton.bezelStyle = .rounded
        createButton.keyEquivalent = "\r" // enter
        createButton.translatesAutoresizingMaskIntoConstraints = false

        // StackView для выравнивания
        let stack = NSStackView(views: [
            nameLabel, nameField,
            timeLabel, timeField,
            createButton
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            nameField.widthAnchor.constraint(equalToConstant: 280),
            timeField.widthAnchor.constraint(equalToConstant: 100),
            createButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    @objc func create() {
        let name = nameField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let minutes = Int(timeField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        guard !name.isEmpty, minutes > 0 else { return }

        ScenarioManager.shared.add(name: name, durationMinutes: minutes)
        self.window?.close()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
