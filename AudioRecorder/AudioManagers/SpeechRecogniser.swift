import Foundation
import SwiftUI
import AVFoundation
import Combine
import Speech

class SpeechRecogniser {
    static var isFound = false
    
    public static func hasSpeech(audioURL: URL, onFound: @escaping (Bool) -> Void) {
        isFound = false
        
        let recogniser = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        
        request.shouldReportPartialResults = false
        
        print("SpeechRecogniser.isAvailable = \(recogniser?.isAvailable)")
        if (recogniser?.isAvailable)! {
            
            var recognitionTask: SFSpeechRecognitionTask!
            recognitionTask = recogniser?.recognitionTask(with: request) { result, error in
                if isFound {
                    //recognitionTask.cancel();
                    //recognitionTask.finish();
                    
                    print("RETURN form here mafaka")
                    return
                }
                guard let result = result else {
                    print("SpeechRecogniser.No result!");
                    onFound(false);
                    
                    recognitionTask.cancel();
                    recognitionTask.finish();
                    
                    return
                }
                
                guard error == nil else {
                    print("SpeechRecogniser.Error: \(error!)");
                    
                    return
                }
                
                print("SpeechRecogniser.result.transcriptions.count = \(result.transcriptions.count)")
                print("SpeechRecogniser.Best recognised text: \(result.bestTranscription.formattedString)")
                
                let hasFound = !result.bestTranscription.formattedString.isEmpty || result.transcriptions.count > 0
                
                print("SpeechRecogniser.HasFound \(hasFound)")
                
                recognitionTask.cancel()
                recognitionTask.finish()
                
                isFound = true

                onFound(hasFound)
                print("found")
                
                return
            }
        } else {
            print("SpeechRecogniser.Device doesn't support speech recognition")
        }
    }
}
