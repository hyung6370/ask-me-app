//
//  SpeechRecognitionService.swift
//  STTTTS
//
//  Created by KIM Hyung Jun on 2023/09/05.
//

import Foundation
import googleapis

typealias SpeechRecognitionCompletionHandler = (StreamingRecognizeResponse?, NSError?) -> (Void)

class SpeechRecognitionService {
  var sampleRate: Int = 16000
  private var streaming = false

  private var client : Speech!
  private var writer : GRXBufferedPipe!
  private var call : GRPCProtoCall!

  static let sharedInstance = SpeechRecognitionService()

  func streamAudioData(_ audioData: NSData, completion: @escaping SpeechRecognitionCompletionHandler) {
    if (!streaming) {
      client = Speech(host: "speech.googleapis.com")
      print("client: \(String(describing: client))")
      writer = GRXBufferedPipe()
      call = client.rpcToStreamingRecognize(withRequestsWriter: writer,
                                            eventHandler:
        { (done, response, error) in
                                              completion(response, error as? NSError)
      })
        
      call.requestHeaders.setObject(NSString(string:"\(Bundle.main.googleSTTKey)"),
                                    forKey:NSString(string:"X-Goog-Api-Key"))
      call.requestHeaders.setObject(NSString(string:Bundle.main.bundleIdentifier!),
                                    forKey:NSString(string:"X-Ios-Bundle-Identifier"))

      print("HEADERS:\(call.requestHeaders)")

      call.start()
      streaming = true

      let recognitionConfig = RecognitionConfig()
      recognitionConfig.encoding =  .linear16
      recognitionConfig.sampleRateHertz = Int32(sampleRate)
      recognitionConfig.languageCode = "ko-KR"
      recognitionConfig.maxAlternatives = 30
      recognitionConfig.enableWordTimeOffsets = true

      let streamingRecognitionConfig = StreamingRecognitionConfig()
      streamingRecognitionConfig.config = recognitionConfig
      streamingRecognitionConfig.singleUtterance = false
      streamingRecognitionConfig.interimResults = true

      let streamingRecognizeRequest = StreamingRecognizeRequest()
      streamingRecognizeRequest.streamingConfig = streamingRecognitionConfig

      writer.writeValue(streamingRecognizeRequest)
    }

    let streamingRecognizeRequest = StreamingRecognizeRequest()
    streamingRecognizeRequest.audioContent = audioData as Data
    writer.writeValue(streamingRecognizeRequest)
  }

  func stopStreaming() {
    if (!streaming) {
      return
    }
    writer.finishWithError(nil)
    streaming = false
  }

  func isStreaming() -> Bool {
    return streaming
  }

}
