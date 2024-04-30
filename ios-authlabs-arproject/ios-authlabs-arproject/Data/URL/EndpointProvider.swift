
import Foundation

struct Endpoint: EndpointProvidable {
    private let apiHost: String
    private let urlInformation: URLInformation
    private let scheme: String
    
    init(apiHost: APIHostType, urlInformation: URLInformation, scheme: SchemeType) {
        self.apiHost = apiHost.rawValue
        self.urlInformation = urlInformation
        self.scheme = scheme.rawValue
    }
    
    var url: URL? {
        var urlComponent = URLComponents()
        urlComponent.scheme = scheme
        urlComponent.host = apiHost
        urlComponent.path = urlInformation.path
        if urlInformation.queryItem != nil {
            urlComponent.queryItems = urlInformation.queryItem
        }
        return urlComponent.url
    }
}
