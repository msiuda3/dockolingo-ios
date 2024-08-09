import SwiftUI

class TestResultViewModel: ObservableObject {
    @Published var result: TestResult?
    @Published var loading = false
    @Published var error: String?

    func fetchTestResult(id: Int) {
        guard let token = TokenManager.shared.getToken() else {
            self.error = "No token available"
            self.loading = false
            return
        }

        guard let url = URL(string: "http://localhost:8080/api/courses/result/\(id)") else { return }

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
                    let result = try JSONDecoder().decode(TestResult.self, from: data)
                    self.result = result
                } catch {
                    self.error = error.localizedDescription
                }
            }
        }.resume()
    }
}
