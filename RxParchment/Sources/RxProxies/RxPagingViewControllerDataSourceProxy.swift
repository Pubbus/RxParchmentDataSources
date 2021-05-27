//
//  RxPagingViewControllerDataSourceProxy.swift
//  RxParchment
//
//  Created by Le Phi Hung on 10/19/19.
//  Copyright © 2019 Pubbus. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import Parchment
import RxCocoa

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"


extension PagingViewController: HasDataSource{
    public typealias DataSource = PagingViewControllerDataSource
}

private let pagingViewDataSourceNotSet = PagingViewDataSourceNotSet()

private final class PagingViewDataSourceNotSet
: NSObject
  , PagingViewControllerDataSource {
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        PagingIndexItem(index: index, title: "")
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        rxAbstractMethod(message: dataSourceNotSet)
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 0
    }
}
/// For more information take a look at `DelegateProxyType`.
open class RxPagingViewControllerDataSourceProxy
: DelegateProxy<PagingViewController, PagingViewControllerDataSource>
  , DelegateProxyType
  , PagingViewControllerDataSource {
    public func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return (_requiredMethodsDataSource ?? pagingViewDataSourceNotSet).pagingViewController(pagingViewController ?? PagingViewController(), pagingItemAt: index)
    }
    
    /// Typed parent object.
    public weak private(set) var pagingViewController: PagingViewController?
    
    /// - parameter tableView: Parent object for delegate proxy.
    public init(pagingViewController: PagingViewController) {
        self.pagingViewController = pagingViewController
        super.init(parentObject: pagingViewController, delegateProxy: RxPagingViewControllerDataSourceProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxPagingViewControllerDataSourceProxy(pagingViewController: $0) }
    }
    
    private weak var _requiredMethodsDataSource: PagingViewControllerDataSource? = pagingViewDataSourceNotSet
    
    // MARK: delegate
    
    public func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return (_requiredMethodsDataSource ?? pagingViewDataSourceNotSet).numberOfViewControllers(in: pagingViewController)
    }
    
    public func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController  {
        return (_requiredMethodsDataSource ?? pagingViewDataSourceNotSet).pagingViewController(pagingViewController, viewControllerAt: index)
    }
    
    public func pagingViewController<T>(_ pagingViewController: PagingViewController, pagingItemForIndex index: Int) -> T where T : PagingItem, T : Comparable, T : Hashable {
        return (_requiredMethodsDataSource ?? pagingViewDataSourceNotSet).pagingViewController(pagingViewController, pagingItemAt: index) as! T
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open override func setForwardToDelegate(_ forwardToDelegate: PagingViewControllerDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate  ?? pagingViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
    
}
#endif
