import Foundation
import Combine

protocol Mappable {
    func mapChatGPTContent(with messages: [RequestMessage]) -> AnyPublisher<[GPTAnswer], Error>
    func mapGoogleImageData(with searchWord: String) -> AnyPublisher<[URL], Error>
}


