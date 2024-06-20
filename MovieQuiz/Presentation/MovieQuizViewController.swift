import UIKit

final class MovieQuizViewController: UIViewController,
                                     QuestionFactoryDelegate,
                                     AlertPresenterProtocol {

    // MARK: IB Outlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet var staticTopLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Private Prorerties
    //private var correctAnswers = 0
    private let bigFont = UIFont(name: "YSDisplay-Bold", size: 23)
    private let mediumFont = UIFont(name: "YSDisplay-Medium", size: 20)
    private var questionFactory: QuestionFactoryProtocol?
    var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var alertDelegate: MovieQuizViewControllerDelelegate?
    private var statisticService: StatisticServiceProtocol?
    private let presenter = MovieQuizPresenter()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        statisticService = StatisticService()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory.setup(delegate: self)
        self.questionFactory = questionFactory
        
        let alertDelegate = AlertPresenter()
        alertDelegate.alertController = self
        self.alertDelegate = alertDelegate
        
        questionFactory.loadData()
        presenter.viewController = self
        
        textLabel.font = bigFont
        counterLabel.font = mediumFont
        noButton.titleLabel?.font = mediumFont
        yesButton.titleLabel?.font = mediumFont
        staticTopLabel.font = mediumFont
    }
    
    // MARK: IB Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButttonClicked(_ sender: UIButton) {
        presenter.noButttonClicked()
    }
    
    // MARK: Public Methods
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func showNextQuestionOrResults() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
        
    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            presenter.didAnswer(isCorrectAnswer: isCorrect)
        }
        imageView.layer.borderColor = CGColor(gray: 0.0, alpha: 1)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect
        ? UIColor.ypGreen.cgColor
        : UIColor.ypRed.cgColor
        changeStateButton(isEnabled: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        imageView.layer.borderColor = CGColor(gray: 0.0, alpha: 0)
        changeStateButton(isEnabled: true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        if let statisticService = statisticService {
            statisticService.store(
                correct: presenter.correctAnswers,
                total: presenter.questionsAmount
            )
        }
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
            questionFactory?.requestNextQuestion()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.questionFactory = self.questionFactory
            presenter.showNextQuestionOrResults()
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Private Methods
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            presenter.resetQuestionIndex()
            presenter.restartGame()
            
            self.questionFactory?.requestNextQuestion()
        }
        alertDelegate?.show(alertModel: model)
    }
    
    private func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
}
