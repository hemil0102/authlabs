import Foundation

enum URLInformation {
    case gptImageSearch
    case googleImageSearch(searchWord: String, apiKey: String, cx: String)
    
    var path: String {
        switch self {
        case .gptImageSearch:
            return "/v1/chat/completions"
        case .googleImageSearch:
            return "/customsearch/v1"
        }
    }
    
    var queryItem: [URLQueryItem]? {
        let urlQueryItems: [URLQueryItem]? = nil
        
        switch self {
        case .gptImageSearch:
            return urlQueryItems
        case .googleImageSearch(let searchWord, let apiKey, let cx):
            return [ URLQueryItem(name: "q", value: searchWord),
                URLQueryItem(name: "key", value: apiKey),
                URLQueryItem(name: "cx", value: cx) ]
        }
    }
}
