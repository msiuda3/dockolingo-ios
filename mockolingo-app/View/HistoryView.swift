import SwiftUI

class HistoryViewModel: ObservableObject {
    @Published var courses: [Course] = []
    @Published var loading = false
    @Published var error: String?

    func fetchCourses() {
        
        guard let token = TokenManager.shared.getToken() else {
            self.error = "No token available"
            self.loading = false
            return
        }
        
        guard let url = URL(string: "http://localhost:8080/api/courses/history") else { return }
        
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

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()

    var body: some View {
            NavigationView {
                VStack {
                    if viewModel.loading {
                        Text("Loading...")
                    } else if let error = viewModel.error {
                        Text("Error: \(error)")
                    } else {
                        List(viewModel.courses) { course in
                            NavigationLink(destination: TestResultView(courseId: course.id)) {
                                Text(course.coursename)
                            }
                        }
                        .navigationTitle("Historia")
                    }
                }
                .onAppear {
                    if !viewModel.loading {
                        viewModel.fetchCourses()
                    }
                }
            }
        }
}


struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
