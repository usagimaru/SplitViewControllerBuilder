//
//  SampleData.swift
//  SplitViewControllerBuilderDemo
//

import Foundation

// MARK: - サイドバー用階層データ
// NSOutlineViewのitemがAnyObject?を要求するためclassで定義

class SidebarNode {
	let title: String
	let symbolName: String
	let children: [SidebarNode]?

	var isLeaf: Bool { children == nil }

	init(title: String, symbolName: String, children: [SidebarNode]? = nil) {
		self.title = title
		self.symbolName = symbolName
		self.children = children
	}
}

// MARK: - メッセージデータ

struct MessageItem {
	let id: UUID
	let sender: String
	let subject: String
	let body: String
	let date: Date
	let isRead: Bool
	let hasAttachment: Bool
	/// SidebarNodeのtitleと対応するカテゴリ名
	let category: String
}

// MARK: - サンプルデータ

enum SampleData {

	static let sidebarCategories: [SidebarNode] = [
		SidebarNode(title: "Favorites", symbolName: "star.fill", children: [
			SidebarNode(title: "Inbox", symbolName: "tray.fill"),
			SidebarNode(title: "Drafts", symbolName: "doc.text"),
			SidebarNode(title: "Sent", symbolName: "paperplane.fill"),
		]),
		SidebarNode(title: "Smart Mailboxes", symbolName: "gearshape", children: [
			SidebarNode(title: "Unread", symbolName: "envelope.badge.fill"),
			SidebarNode(title: "Attachments", symbolName: "paperclip"),
		]),
	]

	static let messages: [MessageItem] = {
		let cal = Calendar.current
		let now = Date()

		return [
			MessageItem(
				id: UUID(),
				sender: "Alice Johnson",
				subject: "Project Update",
				body: "Hi,\n\nHere is the latest update on the project. We've completed the first milestone and are moving on to the next phase.\n\nBest regards,\nAlice",
				date: cal.date(byAdding: .hour, value: -1, to: now)!,
				isRead: true,
				hasAttachment: false,
				category: "Inbox"),
			MessageItem(
				id: UUID(),
				sender: "Bob Smith",
				subject: "Meeting Tomorrow",
				body: "Hello,\n\nJust a reminder about our meeting tomorrow at 10 AM. Please bring the design documents.\n\nThanks,\nBob",
				date: cal.date(byAdding: .hour, value: -3, to: now)!,
				isRead: false,
				hasAttachment: false,
				category: "Inbox"),
			MessageItem(
				id: UUID(),
				sender: "Carol Davis",
				subject: "Design Review Feedback",
				body: "Hi team,\n\nAttached is my feedback on the latest design iteration. Overall it looks great, but I have a few suggestions.\n\nCheers,\nCarol",
				date: cal.date(byAdding: .hour, value: -5, to: now)!,
				isRead: true,
				hasAttachment: true,
				category: "Inbox"),
			MessageItem(
				id: UUID(),
				sender: "David Lee",
				subject: "Invoice #1234",
				body: "Hello,\n\nPlease find the invoice attached for last month's services.\n\nRegards,\nDavid",
				date: cal.date(byAdding: .day, value: -1, to: now)!,
				isRead: true,
				hasAttachment: true,
				category: "Inbox"),
			MessageItem(
				id: UUID(),
				sender: "Me",
				subject: "Re: Project Update",
				body: "Thanks for the update, Alice. Everything looks good.\n\nBest,\nMe",
				date: cal.date(byAdding: .hour, value: -2, to: now)!,
				isRead: true,
				hasAttachment: false,
				category: "Sent"),
			MessageItem(
				id: UUID(),
				sender: "Me",
				subject: "Re: Meeting Tomorrow",
				body: "Sure, I'll be there. See you at 10.\n\nThanks,\nMe",
				date: cal.date(byAdding: .hour, value: -2, to: now)!,
				isRead: true,
				hasAttachment: false,
				category: "Sent"),
			MessageItem(
				id: UUID(),
				sender: "Me",
				subject: "Draft: Proposal",
				body: "This is a draft of the proposal for the new feature. Still working on the details...",
				date: cal.date(byAdding: .day, value: -2, to: now)!,
				isRead: true,
				hasAttachment: false,
				category: "Drafts"),
			MessageItem(
				id: UUID(),
				sender: "Eve Wilson",
				subject: "API Documentation",
				body: "Hi,\n\nI've attached the updated API documentation for your review. Let me know if anything needs to be changed.\n\nBest,\nEve",
				date: cal.date(byAdding: .day, value: -3, to: now)!,
				isRead: false,
				hasAttachment: true,
				category: "Inbox"),
		]
	}()

	/// 指定カテゴリに対応するメッセージを返す
	static func messages(for category: SidebarNode?) -> [MessageItem] {
		guard let category else { return [] }

		switch category.title {
			case "Unread":
				return messages.filter { !$0.isRead }
			case "Attachments":
				return messages.filter { $0.hasAttachment }
			default:
				return messages.filter { $0.category == category.title }
		}
	}
}
