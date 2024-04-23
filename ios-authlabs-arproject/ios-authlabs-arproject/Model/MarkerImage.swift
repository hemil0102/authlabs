
import Foundation

struct MarkerImage {
    let name: String
    let marker: Marker
    let category: Classification
    let description: String
}

enum Marker {
    case printed
    case captured
    case realObject
}

enum Classification: String {
    case tag
    case logo
    case text
    case picture
    case plant
    case animal
    case human
    case object
}

let markerImages = [
    MarkerImage(name: "QRCode", marker: .printed, category: .tag, description: "QR Code입니다. Quick Response Code의 약어죠."),
    MarkerImage(name: "Starbucks", marker: .printed, category: .logo, description: "스타벅스라는 브랜드명은 소설 '모비딕'의 일등 항해사 이름에서 유래했다."),
    MarkerImage(name: "StayHungryStayFoolish", marker: .printed, category: .text, description: "끊임없이 갈망하며, 바보처럼 도전하십시오 - 스티브 잡스")
]
