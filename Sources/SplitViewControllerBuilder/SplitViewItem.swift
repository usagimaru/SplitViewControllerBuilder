//
//  NSSplitViewItem.swift
//
//  Created by usagimaru on 2024/03/06.
//  Copyright © 2024 usagimaru.
//

import Cocoa

class SplitViewItem: NSSplitViewItem {
	
	static let defaultDuration: TimeInterval = 0.45
	
	static func easeOutQuintAnimation(duration: TimeInterval?) -> CABasicAnimation {
		let anim = CABasicAnimation()
		anim.duration = duration ?? defaultDuration
		anim.timingFunction = CAMediaTimingFunction.easeOutQuint()
		return anim
	}
	
	override class func defaultAnimation(forKey key: NSAnimatablePropertyKey) -> Any? {
		if NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
			return nil
		}
		
		// isCollapsedのアニメーションを変える
		if key == "collapsed" {
			return Self.easeOutQuintAnimation(duration: nil)
		}
		else {
			return super.defaultAnimation(forKey: key)
		}
	}
	
}

extension NSSplitViewItem {
	
	@discardableResult
	func toggleCollapsed(animated: Bool) -> Bool {
		if animated && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
			animator().isCollapsed.toggle()
		}
		else {
			isCollapsed.toggle()
		}
		
		return isCollapsed
	}
	
	/// Run `Bool.toggle()` to `isCollapsed` when `state` is nil
	@discardableResult
	func setCollapsed(_ state: Bool?, animated: Bool) -> Bool {
		if animated && !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion {
			if let state {
				animator().isCollapsed = state
			}
			else {
				animator().isCollapsed.toggle()
			}
		}
		else {
			if let state {
				isCollapsed = state
			}
			else {
				isCollapsed.toggle()
			}
		}
		
		return isCollapsed
	}
	
}
