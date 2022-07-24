import Foundation
import RxRelay
import RxSwift
import Combine

extension RemoteSettingsClient {
    public static func constant(_ value: Value) -> RemoteSettingsClient {
        RemoteSettingsClient(
            value: { value },
            setup: {},
            asObservable: {
                Observable.just(value)
                    .concat(Observable.never())
                    .observeOn(MainScheduler.instance)
            }, asPublisher: {
                Just(value)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            })
    }
}
