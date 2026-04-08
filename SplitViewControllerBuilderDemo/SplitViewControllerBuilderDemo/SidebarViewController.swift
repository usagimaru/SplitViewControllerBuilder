//
//  SidebarViewController.swift
//  SplitViewControllerBuilderDemo
//

import Cocoa

// MARK: - Delegate

@MainActor
protocol SidebarViewControllerDelegate: AnyObject {
	func sidebarViewController(_ viewController: SidebarViewController,
							   didSelectCategory category: SidebarNode?)
}

// MARK: - SidebarViewController

class SidebarViewController: NSViewController {

	weak var delegate: SidebarViewControllerDelegate?

	private var outlineView: NSOutlineView!
	private let categories = SampleData.sidebarCategories

	private let columnID = NSUserInterfaceItemIdentifier("SidebarColumn")
	private let cellID = NSUserInterfaceItemIdentifier("SidebarCell")


	// MARK: -

	override func loadView() {
		view = NSView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let column = NSTableColumn(identifier: columnID)
		column.title = ""

		let outlineView = NSOutlineView()
		outlineView.addTableColumn(column)
		outlineView.outlineTableColumn = column
		outlineView.style = .sourceList
		outlineView.floatsGroupRows = false
		outlineView.headerView = nil
		outlineView.dataSource = self
		outlineView.delegate = self
		outlineView.rowSizeStyle = .default
		self.outlineView = outlineView

		let scrollView = NSScrollView()
		scrollView.documentView = outlineView
		scrollView.hasVerticalScroller = true
		scrollView.automaticallyAdjustsContentInsets = true
		scrollView.drawsBackground = false

		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	override func viewDidAppear() {
		super.viewDidAppear()
		// トップレベルカテゴリを展開
		for category in categories {
			outlineView.expandItem(category)
		}
	}
}


// MARK: - NSOutlineViewDataSource

extension SidebarViewController: NSOutlineViewDataSource {

	func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		if let node = item as? SidebarNode {
			return node.children?.count ?? 0
		}
		return categories.count
	}

	func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		if let node = item as? SidebarNode {
			return node.children![index]
		}
		return categories[index]
	}

	func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		if let node = item as? SidebarNode {
			return !node.isLeaf
		}
		return false
	}
}


// MARK: - NSOutlineViewDelegate

extension SidebarViewController: NSOutlineViewDelegate {

	func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
		guard let node = item as? SidebarNode else { return nil }

		let cellView: NSTableCellView
		if let reused = outlineView.makeView(withIdentifier: cellID, owner: self) as? NSTableCellView {
			cellView = reused
		}
		else {
			cellView = NSTableCellView()
			cellView.identifier = cellID

			let imageView = NSImageView()
			imageView.translatesAutoresizingMaskIntoConstraints = false
			cellView.addSubview(imageView)
			cellView.imageView = imageView

			let textField = NSTextField(labelWithString: "")
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.lineBreakMode = .byTruncatingTail
			cellView.addSubview(textField)
			cellView.textField = textField

			NSLayoutConstraint.activate([
				imageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 2),
				imageView.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
				imageView.widthAnchor.constraint(equalToConstant: 16),
				imageView.heightAnchor.constraint(equalToConstant: 16),
				textField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 4),
				textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -2),
				textField.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
			])
		}

		cellView.textField?.stringValue = node.title
		cellView.imageView?.image = NSImage(systemSymbolName: node.symbolName, accessibilityDescription: nil)
		cellView.imageView?.contentTintColor = node.isLeaf ? .controlAccentColor : .secondaryLabelColor

		return cellView
	}

	func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		if let node = item as? SidebarNode {
			return !node.isLeaf
		}
		return false
	}

	func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
		if let node = item as? SidebarNode {
			return node.isLeaf
		}
		return false
	}

	func outlineViewSelectionDidChange(_ notification: Notification) {
		let selectedRow = outlineView.selectedRow
		if selectedRow >= 0, let node = outlineView.item(atRow: selectedRow) as? SidebarNode {
			delegate?.sidebarViewController(self, didSelectCategory: node)
		}
		else {
			delegate?.sidebarViewController(self, didSelectCategory: nil)
		}
	}
}
