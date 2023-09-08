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

class ViewController: UIViewController {
    
    @IBOutlet weak var chatGptLabel: UILabel!
    @IBOutlet weak var resultText: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    
    var resultSentence: String = ""
    var isRecording = false
    var audioData: NSMutableData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        navigationItem.title = "Ask me"
        AudioController.sharedInstance.delegate = self
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
    
}

extension ViewController : AudioControllerDelegate {
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
