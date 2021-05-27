//
//  RxParchmentReactiveArrayDataSource.swift
//  RxParchment
//
//  Created by Le Phi Hung on 10/18/19.
//  Copyright © 2019 Pubbus. All rights reserved.
//
#if os(iOS) || os(tvOS)

import UIKit
import RxSwift
import Parchment
import RxCocoa

// objc monkey business
class _RxParchmentReactiveArrayDataSource: NSObject, PagingViewControllerDataSource {
    
    func _numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return 0
    }
    
    func numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return _numberOfViewControllers(in: pagingViewController)
    }
    
    func _pagingViewController(_ pagingViewController: PagingViewController, viewControllerForIndex index: Int) -> UIViewController {
        return UIViewController()
    }
    
    func pagingViewController(_ pagingViewController: PagingViewController, viewControllerAt index: Int) -> UIViewController {
        return _pagingViewController(pagingViewController, viewControllerForIndex: index)
    }
    
    func pagingViewController(_: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        return PagingIndexItem(index: 0, title: "")
    }
}

class RxParchmentReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>
: RxParchmentReactiveArrayDataSource<Sequence.Element>
  , RxParchmentDataSourceType {
    
    typealias Element = Sequence
    
    override init(pagingFactory: @escaping PagingFactory) {
        super.init(pagingFactory: pagingFactory)
    }
    
    func pagingViewController(_ pagingViewController : PagingViewController, observedEvent: Event<Sequence>) {
        Binder(self) { pagingViewControllerDataSource, sectionModels in
            let sections = Array(sectionModels)
            pagingViewControllerDataSource.pagingViewController(pagingViewController, observedElements: sections)
        }.on(observedEvent)
    }
}

// Please take a look at `DelegateProxyType.swift`
class RxParchmentReactiveArrayDataSource<Element>
: _RxParchmentReactiveArrayDataSource
  , SectionedViewDataSourceType {
    typealias PagingFactory = (PagingViewController, Int, Element) -> (controller: UIViewController, title: String)
    
    var itemModels: [Element]?
    
    func modelAtIndex(_ index: Int) -> Element? {
        return itemModels?[index]
    }
    
    func model(at indexPath: IndexPath) throws -> Any {
        precondition(indexPath.section == 0)
        guard let item = itemModels?[indexPath.item] else {
            throw RxCocoaError.itemsNotYetBound(object: self)
        }
        return item
    }
    
    let pagingFactory: PagingFactory
    
    init(pagingFactory: @escaping PagingFactory) {
        self.pagingFactory = pagingFactory
    }
    
    override func pagingViewController(_ pagingViewController: PagingViewController, pagingItemAt index: Int) -> PagingItem {
        let title = pagingFactory(pagingViewController, index, itemModels![index]).title
        return PagingIndexItem(index: index, title: title)
    }
    
    override func _pagingViewController(_ pagingViewController: PagingViewController, viewControllerForIndex index: Int) -> UIViewController {
        return pagingFactory(pagingViewController, index, itemModels![index]).controller
    }
    override func _numberOfViewControllers(in pagingViewController: PagingViewController) -> Int {
        return itemModels?.count ?? 0
    }
    
    // reactive
    func pagingViewController(_ pagingViewController: PagingViewController, observedElements: [Element]) {
        self.itemModels = observedElements
        
        pagingViewController.reloadData()
    }
}

#endif
