import Vapor

struct SendMoneyPayload: Content {
    let to: String
    let asset: String
    let amount: String
}
