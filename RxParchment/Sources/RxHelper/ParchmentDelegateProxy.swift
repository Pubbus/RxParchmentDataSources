//
//  ParchmentDelegateProxy.swift
//  RxParchment
//
//  Created by Le Phi Hung on 10/19/19.
//  Copyright © 2019 Pubbus. All rights reserved.
//

import UIKit
import Parchment
import RxSwift
import RxCocoa

extension ObservableType {
    func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>(ofObject object: DelegateProxy.ParentObject, dataSource: DelegateProxy.Delegate, retainDataSource: Bool, binding: @escaping (DelegateProxy, Event<Element>) -> Void)
        -> Disposable
    where DelegateProxy.ParentObject: PagingViewController {

            let proxy = DelegateProxy.proxy(for: object)

            // ensure dispose unregisterDelegate on main thread
            let unregisterDelegate = ScheduledDisposable(
                scheduler: MainScheduler.instance,
                disposable: DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)
            )

            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
          object.view.layoutIfNeeded()

            let subscription = self.asObservable()
                .observe(on: MainScheduler())
                .catch { error in
                    bindingErrorToInterface(error)
                    return Observable.empty()
                }
                // source can never end, otherwise it would release the subscriber, and deallocate the data source
                .concat(Observable.never())
                .take(until: object.rx.deallocated)
                .subscribe { [weak object] (event: RxSwift.Event<Element>) in

                    if object != nil {
                        // TODO: Enable assert again to prevent Proxy changed
                        // Temporary comment out this to by pass `pod lib lint`
                        // assert(proxy === DelegateProxy.currentDelegate(for: object), "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                    }

                    binding(proxy, event)

                    switch event {
                    case .error(let error):
                        bindingErrorToInterface(error)
                        unregisterDelegate.dispose()
                    case .completed:
                        unregisterDelegate.dispose()
                    default:
                        break
                    }
                }

            return Disposables.create { [weak object] in
                subscription.dispose()
                object?.view.layoutIfNeeded()
                unregisterDelegate.dispose()
            }
    }
}
