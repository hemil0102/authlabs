
import Foundation

protocol APIKey {
    static var OpenAIAPIKey: String { get }
    static var GoogleAPIKey: String { get }
}

struct Utils: APIKey {
    static var OpenAIAPIKey: String {
        guard let filePath = Bundle.main.path(forResource: "DEBUG-Keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else { return "" }
        return plist.object(forKey: "API_KEY") as? String ?? ""
    }
    
    static var GoogleAPIKey: String {
        guard let filePath = Bundle.main.path(forResource: "DEBUG-Keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else { return "" }
        return plist.object(forKey: "GOOGLE_API_KEY") as? String ?? ""
    }
    
    static var GoogleCXKey: String {
        guard let filePath = Bundle.main.path(forResource: "DEBUG-Keys", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else { return "" }
        return plist.object(forKey: "GOOGLE_CX_KEY") as? String ?? ""
    }
}

