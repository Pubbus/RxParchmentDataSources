//
//  RxParchmentDataSourceType.swift
//  RxParchment
//
//  Created by Le Phi Hung on 10/19/19.
//  Copyright © 2019 Pubbus. All rights reserved.
//

#if os(iOS)

import Parchment
import RxSwift

/// Marks data source as `UIPickerView` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxParchmentDataSourceType {
    /// Type of elements that can be bound to picker view.
    associatedtype Element

    /// New observable sequence event observed.
    ///
    /// - parameter pageViewController: Bound picker view.
    /// - parameter observedEvent: Event
    func pagingViewController(_ pageViewController: PagingViewController, observedEvent: Event<Element>)
}

#endif
