import Vapor

struct HookPayload: Content {
    let id, address: String
    let asset: Asset
    let amount: Double
}
