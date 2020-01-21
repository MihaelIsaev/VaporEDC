import Vapor

extension Router {
    public func handleEDCHook(_ successHandler: @escaping (Request, HookPayload) throws -> Future<Void>) {
        post { req throws -> Future<HTTPStatus> in
            return try req.content.decode(HookPayload.self).flatMap { payload in
                return try req.edc().addressHistory(address: payload.address, on: req).flatMap { items in
                    guard items.contains(where: { $0.id == payload.id && $0.amount == payload.amount && $0.isNotified == false }) else {
                        throw Abort(.paymentRequired, reason: "Unatuhorized transaction")
                    }
                    return try successHandler(req, payload).transform(to: .ok)
                }
            }
        }
    }
}
