import SwiftUI

class CoursesViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var loading = true
    @Published var error: String?

    func fetchCourses() {
        guard let token = TokenManager.shared.getToken() else {
            self.error = "No token available"
            self.loading = false
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/courses/available") else { return }

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
                    let coursesResponse = try JSONDecoder().decode([Course].self, from: data)
                    self.courses = coursesResponse
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }
}

struct CoursesListView: View {
    @StateObject private var viewModel = CoursesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Dodajemy przycisk nawigacyjny do HistoryView
                NavigationLink(destination: HistoryView()) {
                    Text("Go to History")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                        .padding(.bottom, 20) // Odstęp pomiędzy przyciskiem a listą kursów
                }

                if viewModel.loading {
                    Text("Loading...")
                } else if let error = viewModel.error {
                    Text("Error: \(error)")
                } else {
                    List(viewModel.courses) { course in
                        NavigationLink(destination: CourseDetailView(courseId: course.id)) {
                            Text(course.coursename)
                        }
                    }
                    .navigationTitle("Courses List")
                }
            }
            .onAppear {
                viewModel.fetchCourses()
            }
            .padding()
        }
    }
}

struct CoursesListView_Previews: PreviewProvider {
    static var previews: some View {
        CoursesListView()
    }
}
