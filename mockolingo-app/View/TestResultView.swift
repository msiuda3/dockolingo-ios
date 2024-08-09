import SwiftUI

struct TestResultView: View {
    @StateObject private var viewModel: TestResultViewModel
    var courseId: Int
    var result: TestResult?

    init(courseId: Int, result: TestResult? = nil) {
        _viewModel = StateObject(wrappedValue: TestResultViewModel())
        self.courseId = courseId
        self.result = result
    }

    var body: some View {
        VStack {
            if viewModel.loading {
                Text("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error)")
            } else if let result = viewModel.result ?? self.result {
                Text("Test Result for \(result.coursename)")
                    .font(.largeTitle)
                    .padding(.bottom, 20)

                List(result.questions) { question in
                    VStack(alignment: .leading) {
                        Text(question.question)
                            .font(.headline)
                        Text("Your answer: \(question.answer)")
                        Text(question.correct ? "Correct" : "Incorrect, correct answer: \(question.correctAnswer)")
                            .foregroundColor(question.correct ? .green : .red)
                    }
                }
                Text("Score: \(result.score)")
                    .font(.title)
                    .padding(.top, 20)

                HStack {
                    NavigationLink(destination: CoursesListView()) {
                        Text("Back to Courses")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    NavigationLink(destination: CourseDetailView(courseId: courseId)) {
                        Text("Retake Test")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 150, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 20)
            } else {
                Text("No result data available.")
            }
        }
        .onAppear {
            if viewModel.result == nil && self.result == nil {
                viewModel.fetchTestResult(id: courseId)
            }
        }
        .padding()
    }
}

struct TestResultView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleQuestionResults = [
            TestResult.QuestionResult(id: 1, question: "Question 1?", answer: "Option A", correct: true, correctAnswer: "Option A"),
            TestResult.QuestionResult(id: 2, question: "Question 2?", answer: "Option B", correct: false, correctAnswer: "Option A"),
            TestResult.QuestionResult(id: 3, question: "Question 3?", answer: "Option C", correct: true, correctAnswer: "Option C")
        ]

        let sampleResult = TestResult(id: 1, coursename: "Sample Course", questions: sampleQuestionResults, score: 2)

        return TestResultView(courseId: 1, result: sampleResult)
    }
}
