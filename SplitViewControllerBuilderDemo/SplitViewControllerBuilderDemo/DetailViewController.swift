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
		view = NSView()
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

		view.addSubview(headerView)

		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

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

		view.addSubview(scrollView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 4),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	private func setupPlaceholderLabel() {
		placeholderLabel = NSTextField(labelWithString: String(localized: "No Selection"))
		placeholderLabel.font = .systemFont(ofSize: 24, weight: .light)
		placeholderLabel.textColor = .tertiaryLabelColor
		placeholderLabel.alignment = .center
		placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(placeholderLabel)

		NSLayoutConstraint.activate([
			placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
