import Vapor

extension Container {
    func edc() throws -> EDC {
        return try make(EDC.self)
    }
}
