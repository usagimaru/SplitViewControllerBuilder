//
//  SplitViewController.swift
//
//  Created by usagimaru on 2024/03/09.
//  Copyright © 2024 usagimaru.
//

import Cocoa

open class SplitViewController: NSSplitViewController {

	public struct SplitItemInfo<T: NSViewController> {
		public let itemIndex: Int
		public let item: NSSplitViewItem
		public let viewController: T
	}
	
	/// NSSplitViewのクラス
	open var splitViewClass: NSSplitView.Type {
		SplitView.self
	}
	
	/// NSSplitViewItemのクラス
	open var splitViewItemClass: NSSplitViewItem.Type {
		SplitViewItem.self
	}
	
	
	// MARK: -

	public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		splitView = configureSplitView()
	}

	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	open func configureSplitView() -> NSSplitView {
		let splitViewClass = self.splitViewClass
		
		let splitView = splitViewClass.init()
		splitView.isVertical = true
		splitView.dividerStyle = .thin
		
		return splitView
	}
	
	@discardableResult
	public func addSidebar(_ viewController: NSViewController) -> NSSplitViewItem {
		let item = makeSplitViewItem(viewController: viewController, behavior: .sidebar)
		insertSplitViewItem(item, at: 0)
		return item
	}
	
	@discardableResult
	public func addContentList(_ viewController: NSViewController) -> NSSplitViewItem {
		let item = makeSplitViewItem(viewController: viewController, behavior: .contentList)
		if splitViewItems.first?.behavior == .sidebar {
			insertSplitViewItem(item, at: 1)
		}
		else {
			insertSplitViewItem(item, at: 0)
		}
		return item
	}
	
	@discardableResult
	public func addInspector(_ viewController: NSViewController) -> NSSplitViewItem {
		let item = makeSplitViewItem(viewController: viewController, behavior: .inspector)
		addSplitViewItem(item)
		return item
	}
	
	@discardableResult
	public func addContentArea(_ viewController: NSViewController, behavior: NSSplitViewItem.Behavior = .default) -> NSSplitViewItem {
		let item = makeSplitViewItem(viewController: viewController, behavior: behavior)
		// inspectorが末尾にある場合はその手前、なければ末尾に追加
		if splitViewItems.last?.behavior == .inspector {
			insertSplitViewItem(item, at: splitViewItems.count - 1)
		}
		else {
			addSplitViewItem(item)
		}
		return item
	}

	/// ItemTypeに応じたNSSplitViewItemを生成
	open func makeSplitViewItem(viewController: NSViewController, behavior: NSSplitViewItem.Behavior) -> NSSplitViewItem {
		let itemClass = self.splitViewItemClass
		
		switch behavior {
			case .sidebar:
				let item = itemClass.init(sidebarWithViewController: viewController)
				item.allowsFullHeightLayout = true
				item.minimumThickness = 300
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .contentList:
				let item = itemClass.init(contentListWithViewController: viewController)
				item.allowsFullHeightLayout = true
				item.minimumThickness = 280
				item.canCollapse = false
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .inspector:
				let item = itemClass.init(inspectorWithViewController: viewController)
				item.allowsFullHeightLayout = true
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			default:
				let item = itemClass.init(viewController: viewController)
				return item
		}
	}
	
	
	// MARK: - Item Accessor

	/// 指定したItemTypeに一致するSplitViewItemを返す
	public func splitViewItems(for behavior: NSSplitViewItem.Behavior) -> [NSSplitViewItem] {
		splitViewItems.filter { $0.behavior == behavior }
	}

	/// 指定したItemTypeに一致する最初のSplitViewItemを返す
	public func firstSplitViewItem(for behavior: NSSplitViewItem.Behavior) -> NSSplitViewItem? {
		splitViewItems.first { $0.behavior == behavior }
	}

	/// Get the first NSSplitViewItem with a class
	public func firstItemForViewControllerClass(_ class: AnyClass) -> NSSplitViewItem? {
		splitViewItems.first { item in
			type(of: item.viewController) == `class`
		}
	}
	
	/// Get the first SplitItemInfo of a pane with the specific view controller type
	public func firstPane<T: NSViewController>() -> SplitItemInfo<T>? {
		if let item = firstItemForViewControllerClass(T.self),
		   let index = splitViewItems.firstIndex(of: item),
		   let vc = item.viewController as? T
		{
			return SplitItemInfo<T>(itemIndex: index, item: item, viewController: vc)
		}
		return nil
	}
	
}

open class SplitView: NSSplitView {
	
	// setPosition(ofDividerAt:)をアニメーション対応にするカスタムプロパティアニメーション
	// https://lists.apple.com/archives/cocoa-dev/2011/Jun/msg00453.html
	// https://stackoverflow.com/questions/33853708/unable-to-animate-a-swift-custom-property-with-animator-osx
	
	open override class func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
		if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
			return nil
		}
		
		if key == "splitPosition" {
			return SplitViewItem.easeOutQuintAnimation(duration: nil)
		}
		else {
			return super.defaultAnimation(forKey: key)
		}
	}
	
}
