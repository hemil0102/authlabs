
import Foundation

struct GPTRequestDTO: Codable {
    let model: GPTModel
    let messages: [RequestMessage]
    let logprobs: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case model, messages, logprobs
    }
}

