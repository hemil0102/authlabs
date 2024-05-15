
import Foundation

struct RequestMessage: Codable {
    let role: Role
    let content: [RequestContent]
    let toolCalls: [ToolCall]?
    
    private enum CodingKeys: String, CodingKey {
        case content, role
        case toolCalls = "tool_calls"
    }
}

struct ReceivedMessage: Codable {
    let role: Role
    let content: String
    let toolCalls: [ToolCall]?
    
    private enum CodingKeys: String, CodingKey {
        case content, role
        case toolCalls = "tool_calls"
    }
}

struct RequestContent: Codable {
    let type: Context
    let text: String?
    let image_url: ImageURL?
}

struct ImageURL: Codable {
    let url: String
}
enum Context: String, Codable {
    case text = "text"
    case image_url = "image_url"
}

struct ToolCall: Codable {
    let id, type: String
    let function: Function
}

struct Function: Codable {
    let name, arguments: String
}
