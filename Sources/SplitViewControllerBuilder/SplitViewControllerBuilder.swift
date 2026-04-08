//
//  SplitViewControllerBuilder.swift
//
//  Created by usagimaru on 2024/03/09.
//  Copyright © 2024 usagimaru.
//

import Cocoa

public extension NSSplitViewController {

	struct SplitItemInfo<T: NSViewController> {
		public let itemIndex: Int
		public let item: NSSplitViewItem
		public let viewController: T
	}
	
	
	// MARK: -
	
	static func build(splitViewClass: NSSplitView.Type = SplitView.self, items: [NSSplitViewItem] = []) -> NSSplitViewController {
		let svc = NSSplitViewController()
		svc.splitView = configureSplitView(class: splitViewClass)
		svc.splitViewItems = items
		return svc
	}
	
	private static func configureSplitView(class: NSSplitView.Type) -> NSSplitView {
		let splitView = `class`.init()
		splitView.isVertical = true
		splitView.dividerStyle = .thin
		
		return splitView
	}

	/// ItemTypeに応じたNSSplitViewItemを生成
	private static func makeSplitViewItem(viewController: NSViewController,
										  behavior: NSSplitViewItem.Behavior,
										  splitViewItemClass: NSSplitViewItem.Type) -> NSSplitViewItem
	{
		switch behavior {
			case .sidebar:
				let item = splitViewItemClass.init(sidebarWithViewController: viewController)
				item.allowsFullHeightLayout = true
				
				// ツールバーボタン（ラベル含む）が十分に収まる最低幅を確保しないと、閉じた時にボタンがオーバーフローしてしまう
				item.minimumThickness = 200
				
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .contentList:
				let item = splitViewItemClass.init(contentListWithViewController: viewController)
				item.allowsFullHeightLayout = true
				item.canCollapse = false
				item.minimumThickness = 250
				
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .inspector:
				let item = splitViewItemClass.init(inspectorWithViewController: viewController)
				item.allowsFullHeightLayout = true
				
				// 同
				item.minimumThickness = 200
				
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			default:
				let item = splitViewItemClass.init(viewController: viewController)
				return item
		}
	}
	
	@discardableResult
	func addSidebar(_ viewController: NSViewController, splitViewItemClass: NSSplitViewItem.Type = SplitViewItem.self) -> NSSplitViewItem {
		let item = Self.makeSplitViewItem(viewController: viewController, behavior: .sidebar, splitViewItemClass: splitViewItemClass)
		insertSplitViewItem(item, at: 0)
		return item
	}
	
	@discardableResult
	func addContentList(_ viewController: NSViewController, splitViewItemClass: NSSplitViewItem.Type = SplitViewItem.self) -> NSSplitViewItem {
		let item = Self.makeSplitViewItem(viewController: viewController, behavior: .contentList, splitViewItemClass: splitViewItemClass)
		if splitViewItems.first?.behavior == .sidebar {
			insertSplitViewItem(item, at: 1)
		}
		else {
			insertSplitViewItem(item, at: 0)
		}
		return item
	}
	
	@discardableResult
	func addInspector(_ viewController: NSViewController, splitViewItemClass: NSSplitViewItem.Type = SplitViewItem.self) -> NSSplitViewItem {
		let item = Self.makeSplitViewItem(viewController: viewController, behavior: .inspector, splitViewItemClass: splitViewItemClass)
		addSplitViewItem(item)
		return item
	}
	
	@discardableResult
	func addContentArea(_ viewController: NSViewController, behavior: NSSplitViewItem.Behavior = .default, splitViewItemClass: NSSplitViewItem.Type = SplitViewItem.self) -> NSSplitViewItem {
		let item = Self.makeSplitViewItem(viewController: viewController, behavior: behavior, splitViewItemClass: splitViewItemClass)
		// inspectorが末尾にある場合はその手前、なければ末尾に追加
		if splitViewItems.last?.behavior == .inspector {
			insertSplitViewItem(item, at: splitViewItems.count - 1)
		}
		else {
			addSplitViewItem(item)
		}
		return item
	}
	
	
	// MARK: - Item Accessor

	/// 指定したItemTypeに一致するSplitViewItemを返す
	func splitViewItems(for behavior: NSSplitViewItem.Behavior) -> [NSSplitViewItem] {
		splitViewItems.filter { $0.behavior == behavior }
	}

	/// 指定したItemTypeに一致する最初のSplitViewItemを返す
	func firstSplitViewItem(for behavior: NSSplitViewItem.Behavior) -> NSSplitViewItem? {
		splitViewItems.first { $0.behavior == behavior }
	}

	/// Get the first NSSplitViewItem with a class
	func firstItemForViewControllerClass(_ class: AnyClass) -> NSSplitViewItem? {
		splitViewItems.first { item in
			type(of: item.viewController) == `class`
		}
	}
	
	/// Get the first SplitItemInfo of a pane with the specific view controller type
	func firstPane<T: NSViewController>() -> SplitItemInfo<T>? {
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
