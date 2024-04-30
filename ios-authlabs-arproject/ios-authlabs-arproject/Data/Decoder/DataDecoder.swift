
import Foundation
import Combine

final class DataDecoder: DataDecodable {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func decodedChatGPTCompletionData<T: Decodable>(with messages: [RequestMessage], type: T.Type) -> AnyPublisher<T, Error> {
        networkManager.requestChatGPTCompletionData(with: messages)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func decodedGoogleImageSearchData<T: Decodable>(with searchWord: String, type: T.Type) -> AnyPublisher<T, Error> {
        let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return networkManager.requestGoogleImageSearchData(with: searchWord)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
