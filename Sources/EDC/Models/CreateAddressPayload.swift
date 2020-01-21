import Vapor

struct CreateAddressPayload: Content {
    let account, hook: String
}
