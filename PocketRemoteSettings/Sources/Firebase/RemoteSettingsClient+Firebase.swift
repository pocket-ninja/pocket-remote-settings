import Foundation

extension RemoteSettingsClient where Value: Decodable {
    public static func firebase(initial value: Value) -> RemoteSettingsClient {
        let service = FirebaseRemoteService(initial: value)

        return RemoteSettingsClient(
            value: service.value,
            setup: service.setup,
            asPublisher: service.asPublisher
        )
    }
}
