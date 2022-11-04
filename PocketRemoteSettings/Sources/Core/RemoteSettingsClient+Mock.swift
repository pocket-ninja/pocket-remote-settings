import Foundation
import Combine

extension RemoteSettingsClient {
    public static func constant(_ value: Value) -> RemoteSettingsClient {
        RemoteSettingsClient(
            value: { value },
            setup: {},
            asPublisher: {
                Just(value)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            })
    }
}
