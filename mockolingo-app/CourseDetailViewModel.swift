import SwiftUI

class CourseDetailViewModel: ObservableObject {
    @Published var course: Course?
    @Published var loading = true
    @Published var error: String?
    @Published var answers: [Int: String] = [:]

    func fetchCourseDetail(id: Int) {
        guard let token = TokenManager.shared.getToken() else {
            self.error = "No token available"
            self.loading = false
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/courses/details/\(id)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.loading = false
                if let error = error {
                    self.error = error.localizedDescription
                    return
                }

                guard let data = data else {
                    self.error = "No data received"
                    return
                }

                do {
                    let course = try JSONDecoder().decode(Course.self, from: data)
                    self.course = course
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }

    func submitAnswers() {
        guard let course = course, let token = TokenManager.shared.getToken() else { return }

        let formattedAnswers = answers.map { (questionId, answer) in
            return ["id": questionId, "answer": answer]
        }

        let responseBody: [String: Any] = [
            "id": course.id,
            "coursename": course.coursename,
            "questions": formattedAnswers
        ]

        guard let url = URL(string: "http://localhost:8080/api/courses/submit") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: responseBody, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Submit error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print("Submit successful: \(String(describing: result))")
                } catch {
                    print("Error parsing response data: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

struct CourseDetailView: View {
    @StateObject private var viewModel = CourseDetailViewModel()
    var courseId: Int

    var body: some View {
        VStack {
            if viewModel.loading {
                Text("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error)")
            } else if let course = viewModel.course {
                Text(course.coursename)
                    .font(.largeTitle)
                    .padding(.bottom, 20)

                if let questions = course.questions {
                    ForEach(questions) { question in
                        VStack(alignment: .leading) {
                            Text(question.question)
                                .font(.headline)
                            HStack {
                                RadioButton(id: question.id, answerId: "a", label: question.a, selectedAnswer: $viewModel.answers)
                                RadioButton(id: question.id, answerId: "b", label: question.b, selectedAnswer: $viewModel.answers)
                                RadioButton(id: question.id, answerId: "c", label: question.c, selectedAnswer: $viewModel.answers)
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    Button(action: {
                        viewModel.submitAnswers()
                    }) {
                        Text("Submit Answers")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 220, height: 60)
                            .background(Color.blue)
                            .cornerRadius(15.0)
                    }
                } else {
                    Text("No questions available")
                }
            } else {
                Text("No course found")
            }
        }
        .onAppear {
            viewModel.fetchCourseDetail(id: courseId)
        }
        .padding()
    }
}

struct RadioButton: View {
    let id: Int
    let answerId: String
    let label: String
    @Binding var selectedAnswer: [Int: String]

    var body: some View {
        HStack {
            Button(action: {
                selectedAnswer[id] = answerId
            }) {
                HStack {
                    if selectedAnswer[id] == answerId {
                        Image(systemName: "largecircle.fill.circle")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                    Text(label)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
