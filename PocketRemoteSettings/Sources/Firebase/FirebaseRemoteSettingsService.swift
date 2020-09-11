import FirebaseRemoteConfig
import Foundation
import RxCocoa
import RxRelay
import RxSwift

final class FirebaseRemoteService<Value: Decodable> {
    func value() -> Value {
        settingsRelay.value
    }

    func asObservable() -> Observable<Value> {
        settingsRelay.observeOn(MainScheduler.instance).asObservable()
    }

    init(initial: Value) {
        settingsRelay = BehaviorRelay(value: initial)
    }

    func setup() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = Environment.isDebug ? 60 : 3600
        remoteConfig.configSettings = settings

        NotificationCenter.default.rx
            .notification(UIApplication.didBecomeActiveNotification)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in self?.fetch() })
            .disposed(by: disposeBag)

        synchronizeSettings()
        fetch()
    }

    private func fetch() {
        remoteConfig.fetchAndActivate { [weak self] status, error in
            guard let self = self else {
                return
            }

            guard status != .error else {
                trace("Failed to fetch config with error: \(error?.localizedDescription ?? "none")")
                return
            }

            trace("Remote config fetched successfully")
            self.synchronizeSettings()
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

        settingsRelay.accept(settings)
    }

    private lazy var remoteConfig = RemoteConfig.remoteConfig()
    private let settingsRelay: BehaviorRelay<Value>
    private let disposeBag = DisposeBag()
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

            if let json = value.jsonValue {
                return (key, json)
            }
            
            if let number = value.numberValue {
                if let string = value.stringValue, string.contains(".") {
                    return (key, number.doubleValue)
                } else {
                    return (key, number.intValue)
                }
            }
            
            guard let string = value.stringValue, !string.isEmpty else {
                return nil
            }
            
            if string == "true" || string == "false" {
                return (key, value.boolValue)
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
