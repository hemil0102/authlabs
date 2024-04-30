import Foundation
import Combine

protocol DataDecodable {
    func decodedChatGPTCompletionData<T: Decodable>(with messages: [RequestMessage], type: T.Type) -> AnyPublisher<T, Error>
    
    func decodedGoogleImageSearchData<T: Decodable>(with searchWord: String, type: T.Type) -> AnyPublisher<T, Error>
}
