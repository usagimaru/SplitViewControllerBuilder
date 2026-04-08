//
//  SplitViewController.swift
//
//  Created by usagimaru on 2024/03/09.
//  Copyright © 2024 usagimaru.
//

import Cocoa

public class SplitViewController: NSSplitViewController {

	public struct SplitItemInfo<T: NSViewController> {
		let itemIndex: Int
		let item: NSSplitViewItem
		let viewController: T
	}
	
	public enum ItemType {
		case standard
		case primarySidebar
		case contentList
		case inspector

		var behavior: NSSplitViewItem.Behavior {
			switch self {
				case .standard:
					return .default
				case .primarySidebar:
					return .sidebar
				case .contentList:
					return .contentList
				case .inspector:
					return .inspector
			}
		}
	}
	
	
	// MARK: -
	
	public convenience init(splitView: NSSplitView = SplitView(),
							primaryLeadingAreaBuilder: () -> (ItemType, NSViewController)?,
							secondaryLeadingAreaBuilder: () -> (ItemType, NSViewController)?,
							contentAreaBuilder: () -> [NSViewController]?,
							trailingAreaBuilder: () -> (ItemType, NSViewController)?)
	{
		self.init()
		self.splitView = splitView
		splitView.isVertical = true
		splitView.dividerStyle = .thin

		// Primary leading area（Sidebar等）
		if let (itemType, vc) = primaryLeadingAreaBuilder() {
			let item = makeSplitViewItem(itemType, viewController: vc)
			addSplitViewItem(item)
		}

		// Secondary leading area（ContentList等）
		if let (itemType, vc) = secondaryLeadingAreaBuilder() {
			let item = makeSplitViewItem(itemType, viewController: vc)
			addSplitViewItem(item)
		}

		// Content area
		if let contentVCs = contentAreaBuilder() {
			for vc in contentVCs {
				let item = NSSplitViewItem(viewController: vc)
				addSplitViewItem(item)
			}
		}

		// Trailing area（Inspector等）
		if let (itemType, vc) = trailingAreaBuilder() {
			let item = makeSplitViewItem(itemType, viewController: vc)
			addSplitViewItem(item)
		}
	}

	/// ItemTypeに応じたNSSplitViewItemを生成
	private func makeSplitViewItem(_ itemType: ItemType, viewController: NSViewController) -> SplitViewItem
	{
		switch itemType {
			case .primarySidebar:
				let item = SplitViewItem(sidebarWithViewController: viewController)
				item.allowsFullHeightLayout = true
				item.minimumThickness = 300
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .contentList:
				let item = SplitViewItem(contentListWithViewController: viewController)
				item.minimumThickness = 300
				item.canCollapse = true
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .inspector:
				let item = SplitViewItem(inspectorWithViewController: viewController)
				item.allowsFullHeightLayout = true
				if #available(macOS 26.0, *) {
					item.automaticallyAdjustsSafeAreaInsets = true
				}
				return item

			case .standard:
				let item = SplitViewItem(viewController: viewController)
				item.holdingPriority = .defaultLow
				return item
		}
	}
	
	
	// MARK: - Item Accessor

	/// 指定したItemTypeに一致するSplitViewItemを返す
	public func splitViewItems(for itemType: ItemType) -> [NSSplitViewItem] {
		splitViewItems.filter { $0.behavior == itemType.behavior }
	}

	/// 指定したItemTypeに一致する最初のSplitViewItemを返す
	public func firstSplitViewItem(for itemType: ItemType) -> NSSplitViewItem? {
		splitViewItems.first { $0.behavior == itemType.behavior }
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

public class SplitView: NSSplitView {
	
	// setPosition(ofDividerAt:)をアニメーション対応にするカスタムプロパティアニメーション
	// https://lists.apple.com/archives/cocoa-dev/2011/Jun/msg00453.html
	// https://stackoverflow.com/questions/33853708/unable-to-animate-a-swift-custom-property-with-animator-osx
	
	public override class func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
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
