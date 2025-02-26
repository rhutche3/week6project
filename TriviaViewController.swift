import UIKit

class TriviaViewController: UIViewController {
  
  @IBOutlet weak var currentQuestionNumberLabel: UILabel!
  @IBOutlet weak var questionContainerView: UIView!
  @IBOutlet weak var questionLabel: UILabel!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var answerButton0: UIButton!
  @IBOutlet weak var answerButton1: UIButton!
  @IBOutlet weak var answerButton2: UIButton!
  @IBOutlet weak var answerButton3: UIButton!
  
  @IBAction func didTapAnswerButton(_ sender: UIButton) {
    updateToNextQuestion(answer: sender.currentTitle ?? "")
}


  
  private var questions = [TriviaQuestion]()
  private var currQuestionIndex = 0
  private var numCorrectQuestions = 0
  private let triviaService = TriviaQuestionService() // ✅ Added service instance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    addGradient()
    questionContainerView.layer.cornerRadius = 8.0
    fetchTriviaQuestions() // ✅ Fixed function call
  }
  
  private func updateQuestion(withQuestionIndex questionIndex: Int) {
    currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
    let question = questions[questionIndex]
    questionLabel.text = question.question
    categoryLabel.text = question.category
    let answers = ([question.correctAnswer] + question.incorrectAnswers).shuffled()
    
    answerButton0.setTitle(answers[0], for: .normal)
    answerButton1.setTitle(answers[1], for: .normal)
    answerButton2.setTitle(answers[2], for: .normal)
    answerButton3.setTitle(answers[3], for: .normal)
    
    answerButton1.isHidden = answers.count <= 1
    answerButton2.isHidden = answers.count <= 2
    answerButton3.isHidden = answers.count <= 3
  }
  
  private func fetchTriviaQuestions() { // ✅ Moved inside class
    triviaService.fetchTriviaQuestions { [weak self] fetchedQuestions in
      DispatchQueue.main.async {
        guard let self = self, let fetchedQuestions = fetchedQuestions else { return }
        self.questions = fetchedQuestions
        self.currQuestionIndex = 0
        self.numCorrectQuestions = 0
        self.updateQuestion(withQuestionIndex: self.currQuestionIndex) // ✅ Fixed function call
      }
    }
  }

  private func updateToNextQuestion(answer: String) {
    if isCorrectAnswer(answer) {
      numCorrectQuestions += 1
    }
    currQuestionIndex += 1
    guard currQuestionIndex < questions.count else {
      showFinalScore()
      return
    }
    updateQuestion(withQuestionIndex: currQuestionIndex)
  }
  
  private func isCorrectAnswer(_ answer: String) -> Bool {
    return answer == questions[currQuestionIndex].correctAnswer
  }
  
  private func showFinalScore() {
    let alertController = UIAlertController(title: "Game over!",
                                            message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                            preferredStyle: .alert)
    let resetAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
      self?.fetchTriviaQuestions()
    }
    alertController.addAction(resetAction)
    present(alertController, animated: true, completion: nil)
  }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
            UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

}

