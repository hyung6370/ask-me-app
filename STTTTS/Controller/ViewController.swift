//
//  ViewController.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/05.
//

import UIKit
import googleapis
import AVFAudio
import Alamofire
import Firebase


class ViewController: UIViewController {
    
    @IBOutlet weak var semiTitleLabel: UILabel!
    @IBOutlet weak var chatGptLabel: UILabel!
    @IBOutlet weak var resultText: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var answerBackView: UIView!
    @IBOutlet weak var meBackView: UIView!
    
    let db = Firestore.firestore()
    
    
    var resultSentence: String = ""
    var isRecording = false
    var audioData: NSMutableData!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Ask me"
        AudioController.sharedInstance.delegate = self

    }
    
    func configureUI() {
        semiTitleLabel.layer.shadowColor = UIColor.darkGray.cgColor
        semiTitleLabel.layer.shadowOffset = CGSize(width: 0, height: 2)
        semiTitleLabel.layer.shadowOpacity = 0.2
        semiTitleLabel.layer.shadowRadius = 4
        
        answerBackView.layer.cornerRadius = 10
        answerBackView.clipsToBounds = false
        answerBackView.layer.shadowColor = UIColor.darkGray.cgColor
        answerBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        answerBackView.layer.shadowOpacity = 0.5
        answerBackView.layer.shadowRadius = 4
        answerBackView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        meBackView.layer.cornerRadius = 10
        meBackView.clipsToBounds = false
        meBackView.layer.shadowColor = UIColor.darkGray.cgColor
        meBackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        meBackView.layer.shadowOpacity = 0.5
        meBackView.layer.shadowRadius = 4
        meBackView.backgroundColor = UIColor(hexCode: "F5F5F4")
        
        startBtn.layer.cornerRadius = 20
        startBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "확인", style: .default) { (action) in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        if isRecording {
            // Stop recording
            isRecording = false
            _ = AudioController.sharedInstance.stop()
            SpeechRecognitionService.sharedInstance.stopStreaming()
            startBtn.setTitle("말하기 시작", for: .normal)
        } else {
            // Start recording
            startBtn.setTitle("말하기 멈추기", for: .normal)
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSession.Category.record)
            } catch {
                print("Failed to set audio session category.")
            }
            
            audioData = NSMutableData()
            _ = AudioController.sharedInstance.prepare(specifiedSampleRate: 16000)
            SpeechRecognitionService.sharedInstance.sampleRate = 16000
            _ = AudioController.sharedInstance.start()
            
            isRecording = true
        }
    }
    
    func askGPT(question: String, completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(Bundle.main.openAIKey)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant."],
                ["role": "user", "content": question]
            ]
        ]
        
        AF.request("https://api.openai.com/v1/chat/completions", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                print("Raw API Response: \(value)")
                if let jsonResponse = value as? [String: Any],
                   let choices = jsonResponse["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let text = message["content"] as? String {
                    completion(text.trimmingCharacters(in: .whitespacesAndNewlines))
                    print("OpenAI Response: \(text)")
                } else {
                    print("Error")
                    completion(nil)
                }
            case .failure(_):
                print("Failure")
                completion(nil)
            }
        }
    }
    
    func saveDataToFirebase() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("유저가 로그인 하지 않았습니다.")
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: date)
        
        let myQuestion = resultText.text ?? ""
        let gptAnswer = chatGptLabel.text ?? ""
        
        let historyItem: [String: Any] = [
            "createDate": dateString,
            "myQuestion": myQuestion,
            "gptAnswer": gptAnswer
        ]
        
        db.collection("users").document(uid).collection("history").document(dateString).setData(historyItem) { err in
            if let err = err {
                print("Error adding data: \(err)")
            }
            else {
                print("Data successfully added")
            }
        }
    }
}

extension ViewController: AudioControllerDelegate {
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)

        // We recommend sending samples in 100ms chunks
        let chunkSize: Int = Int(0.1 * Double(16000) * 2)
        if audioData.length > chunkSize {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion: { [weak self] (response, error) in
                if let error = error {
                    print("error")
                    self?.resultText.text = error.localizedDescription
                } else if let response = response {
                    var finished = false
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult, result.isFinal {
                            let trans = result.alternativesArray[0] as? SpeechRecognitionAlternative
                            finished = true
                            self?.resultText.text = trans?.transcript
                            
                            self?.resultSentence = trans?.transcript ?? ""
                            print(self?.resultSentence)
                        }
                    }
                    if finished {
                        self?.isRecording = false
                        _ = AudioController.sharedInstance.stop()
                        SpeechRecognitionService.sharedInstance.stopStreaming()

                        self?.startBtn.setTitle("말하기 시작", for: .normal)
                        
                        self?.askGPT(question: self?.resultSentence ?? "") { [weak self] response in
                            DispatchQueue.main.async {
                                self?.chatGptLabel.text = response
                                self?.saveDataToFirebase()
                            }
                        }
                    }
                }
            })
            self.audioData = NSMutableData()
        }
    }
}

extension Bundle {
    var googleSTTKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "SecretKey", ofType: "plist") else {
                fatalError("Couldn't find file 'SecretKey.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            
            guard let value = plist?.object(forKey: "GOOGLE_STT_API_KEY") as? String else {
                fatalError("Couldn't find key 'GOOGLE_STT_API_KEY' in 'SecretKey.plist'.")
            }
            return value
        }
    }
    
    var openAIKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "SecretKey", ofType: "plist") else {
                fatalError("Couldn't find file 'SecretKey.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            
            guard let value = plist?.object(forKey: "OPEN_AI_API_KEY") as? String else {
                fatalError("Couldn't find key 'OPEN_AI_API_KEY' in 'SecretKey.plist'.")
            }
            return value
        }
    }
}
