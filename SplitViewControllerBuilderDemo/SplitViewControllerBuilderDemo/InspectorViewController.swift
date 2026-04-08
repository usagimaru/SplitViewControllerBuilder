//
//  InspectorViewController.swift
//  SplitViewControllerBuilderDemo
//

import Cocoa

class InspectorViewController: NSViewController {

	private var scrollView: NSScrollView!
	private var stackView: NSStackView!
	private var placeholderLabel: NSTextField!

	private lazy var dateFormatter: DateFormatter = {
		let f = DateFormatter()
		f.dateStyle = .medium
		f.timeStyle = .short
		return f
	}()


	// MARK: -

	override func loadView() {
		view = NSView()
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupStackView()
		setupPlaceholderLabel()

		showPlaceholder(true)
	}


	// MARK: - Setup

	private func setupStackView() {
		stackView = NSStackView()
		stackView.orientation = .vertical
		stackView.alignment = .leading
		stackView.spacing = 6
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.edgeInsets = NSEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)

		// フリップされたNSViewをdocumentViewに使い、
		// スタックビューを上端寄せにする
		let flipView = FlippedView()
		flipView.translatesAutoresizingMaskIntoConstraints = false
		flipView.addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: flipView.topAnchor),
			stackView.leadingAnchor.constraint(equalTo: flipView.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: flipView.trailingAnchor),
		])

		scrollView = NSScrollView()
		scrollView.documentView = flipView
		scrollView.hasVerticalScroller = true
		scrollView.drawsBackground = false
		scrollView.automaticallyAdjustsContentInsets = true
		scrollView.translatesAutoresizingMaskIntoConstraints = false

		view.addSubview(scrollView)

		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			flipView.widthAnchor.constraint(equalTo: scrollView.contentView.widthAnchor),
		])
	}

	private func setupPlaceholderLabel() {
		placeholderLabel = NSTextField(labelWithString: String(localized: "No Selection"))
		placeholderLabel.font = .systemFont(ofSize: 16, weight: .light)
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
		// 既存のarrangedSubviewsをすべて除去
		for subview in stackView.arrangedSubviews {
			stackView.removeArrangedSubview(subview)
			subview.removeFromSuperview()
		}

		guard let message else {
			showPlaceholder(true)
			return
		}

		showPlaceholder(false)

		// Message Infoセクション
		addSectionHeader(String(localized: "Message Info"))
		addPropertyRow(label: String(localized: "Subject"), value: message.subject)
		addPropertyRow(label: String(localized: "Sender"), value: message.sender)
		addPropertyRow(label: String(localized: "Date"), value: dateFormatter.string(from: message.date))
		addPropertyRow(label: String(localized: "Category"), value: message.category)

		addSeparator()

		// Statusセクション
		addSectionHeader(String(localized: "Status"))
		addPropertyRow(label: String(localized: "Read"),
					   value: message.isRead ? String(localized: "Yes") : String(localized: "No"))
		addPropertyRow(label: String(localized: "Attachment"),
					   value: message.hasAttachment ? String(localized: "Yes") : String(localized: "No"))
	}

	private func showPlaceholder(_ show: Bool) {
		placeholderLabel.isHidden = !show
		scrollView.isHidden = show
	}


	// MARK: - UI Parts

	private func addSectionHeader(_ title: String) {
		let label = NSTextField(labelWithString: title)
		label.font = .systemFont(ofSize: 11, weight: .semibold)
		label.textColor = .secondaryLabelColor
		stackView.addArrangedSubview(label)

		// セクション見出しの上にスペースを追加（最初のセクション以外）
		if stackView.arrangedSubviews.count > 1 {
			stackView.setCustomSpacing(16, after: stackView.arrangedSubviews[stackView.arrangedSubviews.count - 2])
		}
	}

	private func addPropertyRow(label: String, value: String) {
		let labelField = NSTextField(labelWithString: "\(label):")
		labelField.font = .systemFont(ofSize: 12)
		labelField.textColor = .secondaryLabelColor
		labelField.alignment = .right
		labelField.translatesAutoresizingMaskIntoConstraints = false
		labelField.widthAnchor.constraint(equalToConstant: 72).isActive = true
		labelField.setContentHuggingPriority(.required, for: .horizontal)

		let valueField = NSTextField(labelWithString: value)
		valueField.font = .systemFont(ofSize: 12)
		valueField.textColor = .labelColor
		valueField.lineBreakMode = .byWordWrapping
		valueField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

		let rowStack = NSStackView(views: [labelField, valueField])
		rowStack.orientation = .horizontal
		rowStack.alignment = .firstBaseline
		rowStack.spacing = 6
		rowStack.translatesAutoresizingMaskIntoConstraints = false

		stackView.addArrangedSubview(rowStack)
		rowStack.widthAnchor.constraint(equalTo: stackView.widthAnchor,
										constant: -(stackView.edgeInsets.left + stackView.edgeInsets.right)).isActive = true
	}

	private func addSeparator() {
		let separator = NSBox()
		separator.boxType = .separator
		separator.translatesAutoresizingMaskIntoConstraints = false

		stackView.addArrangedSubview(separator)
		separator.widthAnchor.constraint(equalTo: stackView.widthAnchor,
										 constant: -(stackView.edgeInsets.left + stackView.edgeInsets.right)).isActive = true
	}
}


// MARK: - FlippedView
// スクロールビュー内でコンテンツを上端寄せにするためのヘルパー

private class FlippedView: NSView {
	override var isFlipped: Bool { true }
}
