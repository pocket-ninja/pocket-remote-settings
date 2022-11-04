import Foundation
import Combine

@dynamicMemberLookup
public struct RemoteSettingsClient<Value> {
    public var value: () -> Value
    public var setup: () -> Void
    public var asPublisher: () -> AnyPublisher<Value, Never>

    public init(
        value: @escaping () -> Value,
        setup: @escaping () -> Void,
        asPublisher: @escaping () -> AnyPublisher<Value, Never>
    ) {
        self.value = value
        self.setup = setup
        self.asPublisher = asPublisher
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        value()[keyPath: keyPath]
    }
}
