import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("invaild url error", comment: "")
        case .requestFailed:
            return NSLocalizedString("request error", comment: "")
        case .unknown:
            return NSLocalizedString("unknown error", comment: "")
        }
    }
}

