import Vapor

public class EDC: Vapor.Service {
    private let receiveServiceURL = "https://receive.blockchain.mn"
    private let account, token, hookURL: String
    
    // MARK: Initialization
    
    public init (account: String, token: String, hookURL: String) {
        self.account = account
        self.token = token
        self.hookURL = hookURL
    }
    
    public static var environment: EDC {
        guard let account = Environment.get("EDC_ACCOUNT") else {
            fatalError("Please set `EDC_ACCOUNT` environment variable")
        }
        guard let token = ProcessInfo.processInfo.environment["EDC_TOKEN"] else {
            fatalError("Please set `EDC_TOKEN` environment variable")
        }
        guard let hookURL = ProcessInfo.processInfo.environment["EDC_HOOK"] else {
            fatalError("Please set `EDC_HOOK` environment variable")
        }
        return .init(account: account, token: token, hookURL: hookURL)
    }
    
    // MARK: Methods
    
    public func createAddress(on container: Container) throws -> Future<String> {
        let url = "\(receiveServiceURL)/new-account/\(token)"
        return try container.client().post(url, headers: HTTPHeaders([("Content-type","application/json")]), beforeSend: {
            try $0.content.encode(json: CreateAddressPayload(account: self.account, hook: self.hookURL))
        }).map { response in
            guard let data = response.http.body.debugDescription.data(using: .utf8) else { throw EDCError.cantRetrieveAddress }
            return try JSONDecoder().decode(CreateAddressResponse.self, from: data).address
        }
    }
    
    public func addressHistory(address: String, on container: Container) throws -> Future<[HistoryItem]> {
        let decoder = JSONDecoder()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        decoder.dateDecodingStrategy = .formatted(df)
        return try container
            .client()
            .get("\(receiveServiceURL)/history/\(token)/\(address)")
            .flatMap { try $0.content.decode([HistoryItem].self, using: decoder) }
    }
    
    public func sendMoney(to address: String, amount: Double, asset: String = "edc", on container: Container) throws -> Future<Void> {
        let nf = NumberFormatter()
        nf.decimalSeparator = "."
        nf.maximumFractionDigits = 3
        guard let sum = nf.string(from: NSNumber(value: amount)) else { throw EDCError.cantSendMoney }
        let url = "\(receiveServiceURL)/transfer/\(token)"
        return try container.client().post(url, headers: HTTPHeaders([("Content-type","application/json")]), beforeSend: {
            try $0.content.encode(json: SendMoneyPayload(to: address, asset: asset, amount: sum))
        }).map {
            guard $0.http.status == .ok else { throw EDCError.cantSendMoney }
        }
    }
}
