//
//  Parchment+Rx.swift
//  RxParchment
//
//  Created by Le Phi Hung on 10/18/19.
//  Copyright © 2019 Pubbus. All rights reserved.
//
import RxSwift
import Parchment
import RxCocoa

public extension Reactive where Base: PagingViewController {
  func items<Sequence: Swift.Sequence, Source: ObservableType>
      (_ source: Source)
  -> (_ pagingFactory: @escaping (PagingViewController, Int, Sequence.Element) -> (UIViewController, String))
      -> Disposable
      where Source.Element == Sequence {
          return { pagingFactory in
              let dataSource = RxParchmentReactiveArrayDataSourceSequenceWrapper<Sequence>(pagingFactory: pagingFactory)
              return self.items(dataSource: dataSource)(source)
          }
  }

  func items<DataSource: RxParchmentDataSourceType & PagingViewControllerDataSource, O: ObservableType>(dataSource: DataSource)
      -> (_ source: O)
    -> Disposable where DataSource.Element == O.Element {
          return { source in

              let subscription = source
                  .subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak pagingViewController = self.base] (_: RxPagingViewControllerDataSourceProxy, event) -> Void in
                  guard let pagingViewController = pagingViewController else { return }
                    dataSource.pagingViewController(pagingViewController, observedEvent: event)
              }
              return Disposables.create {
                  subscription.dispose()
              }
          }
  }
}
extension Reactive where Base: PagingViewController {
    /**
     Reactive wrapper for `dataSource`.
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var dataSource: DelegateProxy<PagingViewController, PagingViewControllerDataSource> {
        return RxPagingViewControllerDataSourceProxy.proxy(for: base)
    }

    /**
     Installs data source as forwarding delegate on `rx.dataSource`.
     Data source won't be retained.
     It enables using normal delegate mechanism with reactive delegate mechanism.
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func setDataSource(_ dataSource: PagingViewControllerDataSource)
        -> Disposable {
            return RxPagingViewControllerDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
}
