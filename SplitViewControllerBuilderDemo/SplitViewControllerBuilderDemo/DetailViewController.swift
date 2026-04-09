//
//  DetailViewController.swift
//  SplitViewControllerBuilderDemo
//

import Cocoa

class DetailViewController: NSViewController {

	private var headerView: NSView!
	private var subjectLabel: NSTextField!
	private var senderLabel: NSTextField!
	private var dateLabel: NSTextField!
	private var bodyTextView: NSTextView!
	private var placeholderLabel: NSTextField!

	private lazy var dateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateStyle = .long
		f.timeStyle = .short
		return f
	}()


	// MARK: -

	override func loadView() {
		if #available(macOS 26.0, *) {
			let backgroundExtensionView = NSBackgroundExtensionView()
			backgroundExtensionView.automaticallyPlacesContentView = false
			
			let container = NSView()
			container.translatesAutoresizingMaskIntoConstraints = false
			backgroundExtensionView.contentView = container
			view = backgroundExtensionView

			// contentViewをsafe area内に手動配置
			NSLayoutConstraint.activate([
				container.topAnchor.constraint(equalTo: backgroundExtensionView.safeAreaLayoutGuide.topAnchor),
				container.bottomAnchor.constraint(equalTo: backgroundExtensionView.safeAreaLayoutGuide.bottomAnchor),
				container.leadingAnchor.constraint(equalTo: backgroundExtensionView.safeAreaLayoutGuide.leadingAnchor),
				container.trailingAnchor.constraint(equalTo: backgroundExtensionView.safeAreaLayoutGuide.trailingAnchor),
			])
		}
		else {
			view = NSView()
		}
	}

	private var contentContainer: NSView {
		if #available(macOS 26.0, *), let bgView = view as? NSBackgroundExtensionView {
			return bgView.contentView ?? view
		}
		return view
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupHeaderView()
		setupBodyTextView()
		setupPlaceholderLabel()

		showPlaceholder(true)
	}


	// MARK: - Setup

	private func setupHeaderView() {
		headerView = NSView()
		headerView.translatesAutoresizingMaskIntoConstraints = false

		subjectLabel = NSTextField(labelWithString: "")
		subjectLabel.font = .systemFont(ofSize: 18, weight: .semibold)
		subjectLabel.lineBreakMode = .byTruncatingTail
		subjectLabel.translatesAutoresizingMaskIntoConstraints = false

		senderLabel = NSTextField(labelWithString: "")
		senderLabel.font = .systemFont(ofSize: 13)
		senderLabel.textColor = .secondaryLabelColor
		senderLabel.lineBreakMode = .byTruncatingTail
		senderLabel.translatesAutoresizingMaskIntoConstraints = false

		dateLabel = NSTextField(labelWithString: "")
		dateLabel.font = .systemFont(ofSize: 12)
		dateLabel.textColor = .tertiaryLabelColor
		dateLabel.alignment = .right
		dateLabel.lineBreakMode = .byTruncatingTail
		dateLabel.translatesAutoresizingMaskIntoConstraints = false

		headerView.addSubview(subjectLabel)
		headerView.addSubview(senderLabel)
		headerView.addSubview(dateLabel)

		let separator = NSBox()
		separator.boxType = .separator
		separator.translatesAutoresizingMaskIntoConstraints = false
		headerView.addSubview(separator)

		contentContainer.addSubview(headerView)

		// macOS 26: contentContainerは手動でsafe area内に配置済みのためtopAnchorを直接参照
		// 旧OS: contentContainer = viewのためsafeAreaLayoutGuideを参照
		let headerTopAnchor: NSLayoutYAxisAnchor
		if #available(macOS 26.0, *), view is NSBackgroundExtensionView {
			headerTopAnchor = contentContainer.topAnchor
		}
		else {
			headerTopAnchor = contentContainer.safeAreaLayoutGuide.topAnchor
		}

		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: headerTopAnchor),
			headerView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),

			subjectLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
			subjectLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
			subjectLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

			senderLabel.topAnchor.constraint(equalTo: subjectLabel.bottomAnchor, constant: 4),
			senderLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),

			dateLabel.centerYAnchor.constraint(equalTo: senderLabel.centerYAnchor),
			dateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: senderLabel.trailingAnchor, constant: 8),
			dateLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),

			separator.topAnchor.constraint(equalTo: senderLabel.bottomAnchor, constant: 12),
			separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
			separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
			separator.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
		])
	}

	private func setupBodyTextView() {
		let scrollView = NSScrollView()
		scrollView.hasVerticalScroller = true
		scrollView.drawsBackground = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		let textView = NSTextView()
		textView.isEditable = false
		textView.isSelectable = true
		textView.drawsBackground = false
		textView.font = .systemFont(ofSize: 13)
		textView.textColor = .labelColor
		textView.textContainerInset = NSSize(width: 16, height: 12)
		textView.autoresizingMask = [.width]
		scrollView.documentView = textView
		bodyTextView = textView

		contentContainer.addSubview(scrollView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
			scrollView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
		])
	}

	private func setupPlaceholderLabel() {
		placeholderLabel = NSTextField(labelWithString: String(localized: "No Selection"))
		placeholderLabel.font = .systemFont(ofSize: 24, weight: .light)
		placeholderLabel.textColor = .tertiaryLabelColor
		placeholderLabel.alignment = .center
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

		contentContainer.addSubview(placeholderLabel)

		NSLayoutConstraint.activate([
			placeholderLabel.centerXAnchor.constraint(equalTo: contentContainer.centerXAnchor),
			placeholderLabel.centerYAnchor.constraint(equalTo: contentContainer.centerYAnchor),
		])
	}


	// MARK: - Update

	func updateForMessage(_ message: MessageItem?) {
		if let message {
			subjectLabel.stringValue = message.subject
			senderLabel.stringValue = message.sender
			dateLabel.stringValue = dateFormatter.string(from: message.date)
			bodyTextView.string = message.body
			showPlaceholder(false)
		}
		else {
			showPlaceholder(true)
		}
	}

	private func showPlaceholder(_ show: Bool) {
		placeholderLabel.isHidden = !show
		headerView.isHidden = show
		bodyTextView.enclosingScrollView?.isHidden = show
	}
}
