import Foundation

struct GoogleSearchDTO: Decodable {
    let items: [Items]
    
    struct Items: Decodable {
        let title: String?
        let snippet: String?
        let link: String?
        let pagemap: Pagemap
    }
    
    struct Pagemap: Decodable {
        let metatags: [Metatag]
    }
    
    struct Metatag: Decodable {
        let ogImage: String?
        
        enum CodingKeys: String, CodingKey {
            case ogImage = "og:image"
        }
    }
}
