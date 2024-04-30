
import Foundation

struct GPTResponseDTO: Decodable {
    let id, object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    let systemFingerprint: String

    private enum CodingKeys: String, CodingKey {
        case id, object, created, model, choices, usage
        case systemFingerprint = "system_fingerprint"
    }
}

struct Choice: Decodable {
    let index: Int
    let message: ReceivedMessage
    let logprobs: Logprobs?
    let finishReason: String

    private enum CodingKeys: String, CodingKey {
        case index, message, logprobs
        case finishReason = "finish_reason"
    }
}

struct Logprobs: Decodable {
    let content: [Content]?
}

struct Content: Decodable {
    let token: String
    let logprob: Double
    let bytes: [Int]?
    let topLogprobs: [TopLogprobs]
}

struct TopLogprobs: Decodable {
    let token: String
    let logprob: Double
    let buyes: [Int]?
}

struct Usage: Decodable {
    let promptTokens, completionTokens, totalTokens: Int

    private enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}
