
import Foundation
import Combine

final class NetworkManager: Requestable {
    
    func requestChatGPTCompletionData(with messages: [RequestMessage]) -> AnyPublisher<Data, Error> {
        guard let request = RequestProvider(requestInformation: .gptImageSearch(model: .vision, message: messages, logprobs: nil)).request else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299) ~= httpResponse.statusCode else {
                    throw NetworkError.requestFailed
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func requestGoogleImageSearchData(with searchWord: String) -> AnyPublisher<Data, Error> {
        guard let request = RequestProvider(requestInformation: .googleImageSearch(searchWord: searchWord)).request else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299) ~= httpResponse.statusCode else {
                    throw NetworkError.requestFailed
                }
                return data
            }
            .eraseToAnyPublisher()
    }
}

