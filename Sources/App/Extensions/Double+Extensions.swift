import Foundation

extension Double {
	func round(with decimals: Int) -> String {
		return String(format: "%.\(decimals)f", self)
	}
}
