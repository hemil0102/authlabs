
import Foundation

struct RequestProvider: RequestProvidable {
    private let requestInformation: RequestInformation
    
    init(requestInformation: RequestInformation) {
        self.requestInformation = requestInformation
    }
    
    var request: URLRequest? {
        guard let requestUrl = requestInformation.url else { return nil }
        var urlRequest = URLRequest(url: requestUrl)
        urlRequest.httpMethod = requestInformation.httpMethod
        urlRequest.allHTTPHeaderFields = requestInformation.allHTTPHeaderFields
        urlRequest.httpBody = requestInformation.httpBody
        return urlRequest
    }
}
