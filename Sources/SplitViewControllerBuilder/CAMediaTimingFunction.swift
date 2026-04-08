//
//  CAMediaTimingFunction.swift
//
//  Created by usagimaru on 2025/03/17.
//

import QuartzCore

extension CAMediaTimingFunction {
	
	static func easeInQuint() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.64, 0, 0.78, 0)
	}
	static func easeOutQuint() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.22, 1, 0.36, 1)
	}
	static func easeOutExpo() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
	}
	static func easeInCirc() -> CAMediaTimingFunction {
		return CAMediaTimingFunction(controlPoints: 0.55, 0, 1, 0.45)
	}
	
}
