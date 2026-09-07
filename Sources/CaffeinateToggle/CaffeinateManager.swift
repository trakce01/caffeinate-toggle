import Foundation
import Combine

final class CaffeinateManager: ObservableObject {
    @Published var isActive = false {
        didSet {
            if isActive { start() } else { stop() }
        }
    }
    @Published var startedAt: Date?
    @Published var elapsed: String = ""

    private var process: Process?
    private var externalPID: Int32?
    private var timer: Timer?

    init() {
        if let pid = findExistingCaffeinate() {
            externalPID = pid
            startedAt = processStartTime(pid: pid) ?? Date()
            isActive = true
            startTimer()
        }
    }

    func start() {
        guard process == nil, externalPID == nil else { return }
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        proc.arguments = ["-d"]
        proc.terminationHandler = { [weak self] _ in
            DispatchQueue.main.async {
                self?.process = nil
                self?.isActive = false
            }
        }
        do {
            try proc.run()
            process = proc
            startedAt = Date()
            startTimer()
        } catch {
            process = nil
            isActive = false
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let pid = externalPID {
            kill(pid, SIGTERM)
            externalPID = nil
        }
        process?.terminate()
        process = nil
        startedAt = nil
        elapsed = ""
    }

    private func startTimer() {
        updateElapsed()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateElapsed()
        }
    }

    private func updateElapsed() {
        guard let start = startedAt else { elapsed = ""; return }
        let seconds = Int(Date().timeIntervalSince(start))
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            elapsed = String(format: "%dh %02dm", h, m)
        } else if m > 0 {
            elapsed = String(format: "%dm %02ds", m, s)
        } else {
            elapsed = String(format: "%ds", s)
        }
    }

    private func findExistingCaffeinate() -> Int32? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/usr/bin/pgrep")
        proc.arguments = ["-x", "caffeinate"]
        let pipe = Pipe()
        proc.standardOutput = pipe
        do {
            try proc.run()
            proc.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let pid = Int32(output.components(separatedBy: "\n").first ?? "") else {
                return nil
            }
            return pid
        } catch {
            return nil
        }
    }

    private func processStartTime(pid: Int32) -> Date? {
        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: "/bin/ps")
        proc.arguments = ["-o", "lstart=", "-p", String(pid)]
        let pipe = Pipe()
        proc.standardOutput = pipe
        do {
            try proc.run()
            proc.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !output.isEmpty else { return nil }
            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.dateFormat = "EEE MMM d HH:mm:ss yyyy"
            return fmt.date(from: output)
        } catch {
            return nil
        }
    }
}
