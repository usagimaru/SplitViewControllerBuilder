//
//  ToolbarController.swift
//  SplitViewControllerBuilderDemo
//

import Cocoa

extension NSToolbarItem.Identifier {
	static let contentListTrackingSeparator = NSToolbarItem.Identifier("ContentListTrackingSeparator")
}

class ToolbarController: NSObject, NSToolbarDelegate {

	static let toolbarIdentifier = NSToolbar.Identifier("MainToolbar")

	weak var splitView: NSSplitView?


	// MARK: - NSToolbarDelegate

	func toolbar(_ toolbar: NSToolbar,
				 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
				 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem?
	{
		switch itemIdentifier {
			case .toggleSidebar:
				return NSToolbarItem(itemIdentifier: itemIdentifier)

			case .sidebarTrackingSeparator:
				guard let splitView else { return nil }
				return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier,
													  splitView: splitView,
													  dividerIndex: 0)

			case .contentListTrackingSeparator:
				guard let splitView, splitView.arrangedSubviews.count >= 3 else { return nil }
				return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier,
													  splitView: splitView,
													  dividerIndex: 1)

			case .inspectorTrackingSeparator:
				guard let splitView, splitView.arrangedSubviews.count >= 2 else { return nil }
				return NSTrackingSeparatorToolbarItem(identifier: itemIdentifier,
													  splitView: splitView,
													  dividerIndex: splitView.arrangedSubviews.count - 2)

			case .toggleInspector:
				return NSToolbarItem(itemIdentifier: itemIdentifier)

			default:
				return nil
		}
	}

	func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		[
			.toggleSidebar,
			.sidebarTrackingSeparator,
			.contentListTrackingSeparator,
			.flexibleSpace,
			.inspectorTrackingSeparator,
			.flexibleSpace,
			.toggleInspector,
		]
	}

	func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
		toolbarDefaultItemIdentifiers(toolbar)
	}

	func toolbarImmovableItemIdentifiers(_ toolbar: NSToolbar) -> Set<NSToolbarItem.Identifier> {
		[
			.toggleSidebar,
			.sidebarTrackingSeparator,
			.contentListTrackingSeparator,
			.inspectorTrackingSeparator,
			.toggleInspector,
		]
	}
}
