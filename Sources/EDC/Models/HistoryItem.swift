import Foundation
import Vapor

public struct HistoryItem: Content {
    let id: String
    let date: Date
    let amount: Double
    let isNotified: Bool
    let asset: Asset
}
