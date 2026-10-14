import Foundation

struct ContextSnapshot: Codable, Identifiable {
    var id = UUID()
    let thoughtText: String
    let timestamp: Date
    var isActive: Bool
}
