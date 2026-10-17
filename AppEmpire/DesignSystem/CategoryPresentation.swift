import SwiftUI

enum CategoryPresentation {
    static func symbol(for category: String) -> String {
        switch category.lowercased() {
        case "productivity": return "checklist"
        case "finance": return "chart.line.uptrend.xyaxis"
        case "health": return "heart.text.square"
        case "education": return "book.closed"
        case "social": return "person.2"
        case "travel": return "airplane"
        case "food": return "fork.knife"
        case "fitness": return "figure.run"
        case "music": return "music.note"
        case "photo": return "camera"
        case "commerce": return "bag"
        case "games": return "gamecontroller"
        default: return "square.grid.2x2"
        }
    }
}
