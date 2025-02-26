import Foundation

class TriviaQuestionService {
    private let apiURL = "https://opentdb.com/api.php?amount=5&type=multiple"
    
    func fetchTriviaQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        guard let url = URL(string: apiURL) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching trivia questions: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let questions = decodedResponse.results.map { result in
                    TriviaQuestion(
                        category: result.category,
                        question: result.question,
                        correctAnswer: result.correct_answer,
                        incorrectAnswers: result.incorrect_answers
                    )
                }
                completion(questions)
            } catch {
                print("Error decoding trivia questions: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
}

struct TriviaResponse: Decodable {
    let results: [TriviaResult]
}

struct TriviaResult: Decodable {
    let category: String
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}
