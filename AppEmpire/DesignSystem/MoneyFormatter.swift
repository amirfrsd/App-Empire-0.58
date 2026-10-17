import Foundation

enum MoneyFormatter {
    static func cents(_ value: Int64) -> String {
        String(format: "$%.2f", Double(value) / 100.0)
    }
}
