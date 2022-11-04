import FirebaseRemoteConfig
import Foundation
import Combine

final class FirebaseRemoteService<Value: Decodable> {
    func value() -> Value {
        settings
    }

    func asPublisher() -> AnyPublisher<Value, Never> {
        $settings
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    init(initial: Value) {
        settings = initial
    }

    func setup() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = Environment.isDebug ? 60 : 3600
        remoteConfig.configSettings = settings

        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.fetch() }
            .store(in: &cancellables)

        synchronizeSettings()
        fetch()
    }

    private func fetch() {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard status != .error else {
                trace("Failed to fetch config with error: \(error?.localizedDescription ?? "none")")
                return
            }

            trace("Remote config fetched successfully")

            DispatchQueue.main.async {
                self?.synchronizeSettings()
            }
        }
    }

    private func synchronizeSettings() {
        guard
            remoteConfig.lastFetchStatus != .noFetchYet,
            let data = remoteConfig.toJSONData(),
            let settings: Value = try? data.decoded()
        else {
            trace("Failed to synchronize remote settings")
            return
        }

        self.settings = settings
    }

    @Published private var settings: Value
    private var cancellables = Set<AnyCancellable>()
    private lazy var remoteConfig = RemoteConfig.remoteConfig()
}

private enum Environment {
    static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
}

private extension RemoteConfig {
    func toJSONData() -> Data? {
        let keys = allKeys(from: .remote)
        let object: [String: Any] = Dictionary(uniqueKeysWithValues: keys.compactMap { key in
            let value = configValue(forKey: key)

            guard let string = value.stringValue, !string.isEmpty else {
                return nil
            }

            if let json = value.jsonValue {
                return (key, json)
            }

            let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

            if trimmedString.lowercased() == "true" {
                return (key, true)
            }

            if trimmedString.lowercased() == "false" {
                return (key, false)
            }

            if let int = Int(trimmedString) {
                return (key, int)
            }

            if let double = Double(trimmedString) {
                return (key, double)
            }

            return (key, string)
        })

        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }
}

private extension Data {
    func decoded<T: Decodable>() throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}

public func trace(_ message: String = "", file: String = #file, line: Int = #line) {
    guard Environment.isDebug else {
        return
    }

    let filename = file.components(separatedBy: "/").last ?? ""
    print("\(TimestampFormatter.default.timestamp) \(filename):\(line) \(message)")
}

private class TimestampFormatter {
    static let `default` = TimestampFormatter()

    var timestamp: String {
        formatter.string(from: Date())
    }

    init() {
        formatter.dateFormat = "HH:mm:ss:SSS"
    }

    private let formatter = DateFormatter()
}
