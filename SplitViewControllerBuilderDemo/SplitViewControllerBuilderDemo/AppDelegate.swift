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
	private var splitViewController: SplitViewController?

	private var sidebarVC: SidebarViewController?
	private var secondaryListVC: ContentListViewController?
	private var detailVC: DetailViewController?
	private var inspectorVC: InspectorViewController?

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// ---------------------------------------------
		// Setup split view controller with custom panes
		
		let splitViewController = SplitViewController()

		let sidebarVC = SidebarViewController()
		sidebarVC.delegate = self
		self.sidebarVC = sidebarVC
		splitViewController.addSidebar(sidebarVC)

		let contentListVC = ContentListViewController()
		contentListVC.delegate = self
		self.secondaryListVC = contentListVC
		splitViewController.addContentList(contentListVC)

		let detailVC = DetailViewController()
		self.detailVC = detailVC
		splitViewController.addContentArea(detailVC)

		let inspectorVC = InspectorViewController()
		self.inspectorVC = inspectorVC
		splitViewController.addInspector(inspectorVC)

		self.splitViewController = splitViewController
		// ---------------------------------------------

		// Toolbar
		let toolbarController = ToolbarController()
		toolbarController.splitView = splitViewController.splitView
		self.toolbarController = toolbarController

		let toolbar = NSToolbar(identifier: ToolbarController.toolbarIdentifier)
		toolbar.delegate = toolbarController
		toolbar.displayMode = .iconOnly

		// Window
		let wc = NSWindowController(window: window)
		wc.contentViewController = splitViewController
		windowController = wc

		window.styleMask.insert(.fullSizeContentView)
		window.toolbar = toolbar
		window.toolbarStyle = .unified
		window.setContentSize(NSSize(width: 1200, height: 800))

		wc.showWindow(nil)
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
		secondaryListVC?.updateForCategory(category)
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
