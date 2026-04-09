//
//  ContentListViewController.swift
//  SplitViewControllerBuilderDemo
//

import Cocoa

// MARK: - Delegate

@MainActor
protocol ContentListViewControllerDelegate: AnyObject {
	func contentListViewController(_ viewController: ContentListViewController,
								   didSelectMessage message: MessageItem?)
}

// MARK: - ContentListViewController

class ContentListViewController: NSViewController {

	weak var delegate: ContentListViewControllerDelegate?

	private var tableView: NSTableView!
	private var filteredMessages: [MessageItem] = []

	private let subjectColumnID = NSUserInterfaceItemIdentifier("SubjectColumn")
	private let dateColumnID = NSUserInterfaceItemIdentifier("DateColumn")
	private let cellID = NSUserInterfaceItemIdentifier("ContentListCell")

	private lazy var dateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateStyle = .short
		f.timeStyle = .short
		return f
	}()


	// MARK: -

	override func loadView() {
		view = NSView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		let subjectColumn = NSTableColumn(identifier: subjectColumnID)
		subjectColumn.title = String(localized: "Subject")
		subjectColumn.maxWidth = 500
		subjectColumn.resizingMask = .userResizingMask

		let dateColumn = NSTableColumn(identifier: dateColumnID)
		dateColumn.title = String(localized: "Date")
		dateColumn.width = 200
		dateColumn.minWidth = 80
		dateColumn.maxWidth = 300
		dateColumn.resizingMask = .userResizingMask

		let tableView = NSTableView()
		tableView.addTableColumn(subjectColumn)
		tableView.addTableColumn(dateColumn)
		tableView.style = .automatic
		tableView.usesAlternatingRowBackgroundColors = true
		tableView.allowsMultipleSelection = false
		tableView.allowsColumnResizing = true
		tableView.allowsColumnReordering = false
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowSizeStyle = .default
		self.tableView = tableView

		let scrollView = NSScrollView()
		scrollView.documentView = tableView
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalRuler = true
		scrollView.verticalScrollElasticity = .allowed
		scrollView.horizontalScrollElasticity = .automatic
		scrollView.automaticallyAdjustsContentInsets = true

		view.addSubview(scrollView)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	/// カテゴリ選択に応じてメッセージ一覧を更新
	func updateForCategory(_ category: SidebarNode?) {
		filteredMessages = SampleData.messages(for: category)
		tableView.reloadData()
		delegate?.contentListViewController(self, didSelectMessage: nil)
	}
}


// MARK: - NSTableViewDataSource

extension ContentListViewController: NSTableViewDataSource {

	func numberOfRows(in tableView: NSTableView) -> Int {
		filteredMessages.count
	}
}


// MARK: - NSTableViewDelegate

extension ContentListViewController: NSTableViewDelegate {

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard row < filteredMessages.count else { return nil }
		let message = filteredMessages[row]

		let identifier = tableColumn?.identifier ?? cellID
		let cellView: NSTableCellView
		if let reused = tableView.makeView(withIdentifier: identifier, owner: self) as? NSTableCellView {
			cellView = reused
		}
		else {
			cellView = NSTableCellView()
			cellView.identifier = identifier

			let textField = NSTextField(labelWithString: "")
			textField.translatesAutoresizingMaskIntoConstraints = false
			textField.lineBreakMode = .byTruncatingTail
			cellView.addSubview(textField)
			cellView.textField = textField

			NSLayoutConstraint.activate([
				textField.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 4),
				textField.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -4),
				textField.centerYAnchor.constraint(equalTo: cellView.centerYAnchor),
			])
		}

		switch tableColumn?.identifier {
			case subjectColumnID:
				cellView.textField?.stringValue = message.subject
				cellView.textField?.font = message.isRead
					? .systemFont(ofSize: NSFont.systemFontSize)
					: .boldSystemFont(ofSize: NSFont.systemFontSize)

			case dateColumnID:
				cellView.textField?.stringValue = dateFormatter.string(from: message.date)
				cellView.textField?.font = .systemFont(ofSize: NSFont.smallSystemFontSize)
				cellView.textField?.textColor = .secondaryLabelColor

			default:
				break
		}

		return cellView
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		let selectedRow = tableView.selectedRow
		if selectedRow >= 0, selectedRow < filteredMessages.count {
			delegate?.contentListViewController(self, didSelectMessage: filteredMessages[selectedRow])
		}
		else {
			delegate?.contentListViewController(self, didSelectMessage: nil)
		}
	}
}
