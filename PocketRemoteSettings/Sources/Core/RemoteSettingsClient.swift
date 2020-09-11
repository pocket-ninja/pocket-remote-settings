import Foundation
import RxSwift

@dynamicMemberLookup
public struct RemoteSettingsClient<Value> {
    public var value: () -> Value
    public var setup: () -> Void
    public var asObservable: () -> Observable<Value>

    public init(
        value: @escaping () -> Value,
        setup: @escaping () -> Void,
        asObservable: @escaping () -> Observable<Value>
    ) {
        self.value = value
        self.setup = setup
        self.asObservable = asObservable
    }

    public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
        value()[keyPath: keyPath]
    }
}
