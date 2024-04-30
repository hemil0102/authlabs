import Foundation
import Combine

protocol Requestable {
    func requestChatGPTCompletionData(with messages: [RequestMessage]) -> AnyPublisher<Data, Error>
}

