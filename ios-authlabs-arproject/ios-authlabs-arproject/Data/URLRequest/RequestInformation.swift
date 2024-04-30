import Foundation

enum RequestInformation {
    case gptImageSearch(model: GPTModel, message: [RequestMessage], logprobs: Bool?)
    case googleImageSearch(searchWord: String)

    var url: URL? {
        switch self {
        case .gptImageSearch:
            return Endpoint(apiHost: .chatGPT, urlInformation: .gptImageSearch, scheme: .https).url
        case .googleImageSearch(let searchWord):
            return Endpoint(apiHost: .google, urlInformation: .googleImageSearch(searchWord: searchWord, apiKey: Utils.GoogleAPIKey, cx: Utils.GoogleCXKey), scheme: .https).url
        }
    }
    
    var httpMethod: String {
        switch self {
        case .gptImageSearch:
            return "POST"
        case .googleImageSearch:
            return "GET"
        }
    }
    
    var allHTTPHeaderFields: [String : String]? {
        switch self {
        case .gptImageSearch:
            return [ "Content-Type" : "application/json",
                     "Authorization" : "Bearer \(Utils.OpenAIAPIKey)" ]
        case .googleImageSearch:
            return nil
        }
    }
    
    var httpBody: Data? {
        switch self {
        case .gptImageSearch(let model, let messages, let logprobs):
            let data = GPTRequestDTO(model: model, messages: messages, logprobs: logprobs)
            guard let uploadData = try? JSONEncoder().encode(data) else { return nil }
            return uploadData
        case .googleImageSearch:
            return nil
        }
    }
}
