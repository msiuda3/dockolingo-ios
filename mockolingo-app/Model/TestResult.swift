import Foundation

struct TestResult: Decodable {
    struct QuestionResult: Decodable, Identifiable {
        let id: Int
        let question: String
        let answer: String
        let correct: Bool
        let correctAnswer: String
    }

    let id: Int
    let coursename: String
    let questions: [QuestionResult]
    let score: Int
}
