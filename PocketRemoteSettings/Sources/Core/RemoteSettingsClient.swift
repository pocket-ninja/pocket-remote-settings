import Foundation
import RxSwift
import Combine

@dynamicMemberLookup
public struct RemoteSettingsClient<Value> {
    public var value: () -> Value
    public var setup: () -> Void
    public var asObservable: () -> Observable<Value>
    public var asPublisher: () -> AnyPublisher<Value, Never>

    public init(
        value: @escaping () -> Value,
        setup: @escaping () -> Void,
        asObservable: @escaping () -> Observable<Value>,
        asPublisher: @escaping () -> AnyPublisher<Value, Never>
    ) {
        self.value = value
        self.setup = setup
        self.asObservable = asObservable
        self.asPublisher = asPublisher
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        value()[keyPath: keyPath]
    }
}
