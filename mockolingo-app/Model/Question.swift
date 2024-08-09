import Foundation

struct Question: Identifiable, Decodable {
    let id: Int
    let question: String
    let a: String
    let b: String
    let c: String
}
