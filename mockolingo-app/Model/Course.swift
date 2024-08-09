import Foundation

struct Course: Identifiable, Decodable {
    let id: Int
    let coursename: String
    let questions: [Question]?

    init(id: Int, coursename: String, questions: [Question]? = nil) {
        self.id = id
        self.coursename = coursename
        self.questions = questions
    }
}
