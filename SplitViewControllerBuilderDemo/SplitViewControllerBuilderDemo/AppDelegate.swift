//
//  AppDelegate.swift
//  SplitViewControllerBuilderDemo
//
//  Created by usagimaru on 2026/04/04.
//

import Cocoa
import SplitViewControllerBuilder

@main
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet var window: NSWindow!

	private var windowController: NSWindowController?
	private var toolbarController: ToolbarController?

	private var sidebarVC: SidebarViewController?
	private var contentListVC: ContentListViewController?
	private var detailVC: DetailViewController?
	private var inspectorVC: InspectorViewController?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		let sidebarVC = SidebarViewController()
		sidebarVC.delegate = self
		self.sidebarVC = sidebarVC

		let contentListVC = ContentListViewController()
		contentListVC.delegate = self
		self.contentListVC = contentListVC

		let detailVC = DetailViewController()
		self.detailVC = detailVC

		let inspectorVC = InspectorViewController()
		self.inspectorVC = inspectorVC

		let splitViewController = SplitViewController(
			primaryLeadingAreaBuilder: {
				return (.primarySidebar, sidebarVC)
			},
			secondaryLeadingAreaBuilder: {
				return (.contentList, contentListVC)
			},
			contentAreaBuilder: {
				return [detailVC]
			},
			trailingAreaBuilder: {
				return (.inspector, inspectorVC)
			})

		// ツールバー
		let toolbarCtrl = ToolbarController()
		toolbarCtrl.splitView = splitViewController.splitView
		self.toolbarController = toolbarCtrl

		let toolbar = NSToolbar(identifier: ToolbarController.toolbarIdentifier)
		toolbar.delegate = toolbarCtrl
		toolbar.displayMode = .iconOnly

		// ウインドウ
		let wc = NSWindowController(window: window)
		wc.contentViewController = splitViewController
		windowController = wc

		window.styleMask.insert(.fullSizeContentView)
		window.toolbar = toolbar
		window.toolbarStyle = .unified
		window.setContentSize(NSSize(width: 1000, height: 600))

		wc.showWindow(nil)
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}


// MARK: - SidebarViewControllerDelegate

extension AppDelegate: SidebarViewControllerDelegate {

	func sidebarViewController(_ viewController: SidebarViewController,
							   didSelectCategory category: SidebarNode?)
	{
		contentListVC?.updateForCategory(category)
		detailVC?.updateForMessage(nil)
		inspectorVC?.updateForMessage(nil)
	}
}


// MARK: - ContentListViewControllerDelegate

extension AppDelegate: ContentListViewControllerDelegate {

	func contentListViewController(_ viewController: ContentListViewController,
								   didSelectMessage message: MessageItem?)
	{
		detailVC?.updateForMessage(message)
		inspectorVC?.updateForMessage(message)
	}
}
