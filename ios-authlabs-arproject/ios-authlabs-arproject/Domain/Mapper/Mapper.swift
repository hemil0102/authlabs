import Foundation
import Combine

final class Mapper: Mappable {
    private let dataDecoder: DataDecodable
    
    init(dataDecoder: DataDecodable) {
        self.dataDecoder = dataDecoder
    }
    
    func mapChatGPTContent(with messages: [RequestMessage]) -> AnyPublisher<[GPTAnswer], Error> {
        return dataDecoder.decodedChatGPTCompletionData(with: messages, type: GPTResponseDTO.self)
            .receive(on: RunLoop.main)
            .map { result in
                return [GPTAnswer(content: result.choices[0].message.content)]
            }
            .eraseToAnyPublisher()
    }
    
    func mapGoogleImageData(with searchWord: String) -> AnyPublisher<[URL], Error> {
        return dataDecoder.decodedGoogleImageSearchData(with: searchWord, type: GoogleSearchDTO.self)
            .receive(on: RunLoop.main)
            .map { googleSearchDTO in
                
                var imageLinks: [URL] = []
                let pattern = #"^https://.*\.(jpg|jpeg|png|gif|bmp|tiff|heic)$"#
                
                guard let regex = try? NSRegularExpression(pattern: pattern) else {
                    fatalError("Invalid regular expression pattern")
                }

                for item in googleSearchDTO.items {
                    if let imageUrlString = item.pagemap.metatags.first?.ogImage,
                       let match = regex.firstMatch(in: imageUrlString, range: NSRange(imageUrlString.startIndex..., in: imageUrlString)),
                       match.range == NSRange(location: 0, length: imageUrlString.utf16.count),
                       let imageUrl = URL(string: imageUrlString) {
                        imageLinks.append(imageUrl)
                    }
                }

                return imageLinks
            }
            .eraseToAnyPublisher()
    }
}

