import Foundation

enum GPTModel: String, Codable {
    case basic = "gpt-3.5-turbo-1106"
    case vision = "gpt-4-turbo"
}

enum Role: String, Codable {
    case system = "system"
    case user = "user"
    case assistant = "assistant"
}
