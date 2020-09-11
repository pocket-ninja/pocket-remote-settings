import Foundation
import RxRelay
import RxSwift

extension RemoteSettingsClient {
    public static func constant(_ value: Value) -> RemoteSettingsClient {
        RemoteSettingsClient(
            value: { value },
            setup: {},
            asObservable: {
                Observable.just(value)
                    .concat(Observable.never())
                    .observeOn(MainScheduler.instance)
            })
    }

    public static func mutable(_ value: Value) -> (BehaviorRelay<Value>, RemoteSettingsClient) {
        let relay = BehaviorRelay(value: value)

        return (
            relay,
            RemoteSettingsClient(
                value: { relay.value },
                setup: {},
                asObservable: {
                    relay.asObservable().observeOn(MainScheduler.instance)
                }))
    }
}
