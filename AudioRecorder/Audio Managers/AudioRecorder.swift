import Foundation
import SwiftUI
import AVFoundation
import Combine
import Speech

class AudioRecorder: ObservableObject {
    let STARTING_RECORD_DURATION_SECONDS: Double = 10 // 60 * 5 // 5 mins
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var numberOfSamples: Int
    private var timer: Timer?
    private var currentSample: Int = 0
    private var audioRecorder: AVAudioRecorder!
    private var autoRestart: DispatchWorkItem?
    
    public var recordings = [AudioRecord]()
    @Published public var recording = false;
    @Published public var soundSamples: [Float] = []
    
    
    public init(numberOfSamples: Int = 3) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: self.numberOfSamples)
        
        fetchRecordings()
    }
    
    
    func startRecording() {
        do {
            try audioSession.setAllowHapticsAndSystemSoundsDuringRecording(true)
            try audioSession.setCategory(.record, mode: .default, options: .mixWithOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up recording session")
        }
        
        let audioFilename = audioDirectory.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
            startMonitoring()
            
            autoRestart = DispatchWorkItem(block: {
                self.audioRecorder.stop()
                
                DispatchQueue.main.async {
                    self.recognizeSpeech(audioURL: audioFilename) { recognizedText in
                        if recognizedText.isEmpty {
                            self.delete(audioUrl: audioFilename)
                        }
                        
                        self.fetchRecordings()
                    }
                }
                
                self.startRecording()
            })
            if (autoRestart != nil) {
                DispatchQueue.main.asyncAfter(deadline: .now() + STARTING_RECORD_DURATION_SECONDS, execute: autoRestart!)
            }
            
            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        if !recording {
            return
        }
        
        autoRestart?.cancel()
        
        audioRecorder.stop()
        
        stopMonitoring()
        
        try! audioSession.setCategory(.playback, mode: .default, options: AVAudioSession.CategoryOptions.mixWithOthers)
        
        fetchRecordings()
        
        recording = false
    }
    func fetchRecordings() {
        recordings.removeAll()
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        if !fileManager.fileExists(atPath: audioDirectory.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: audioDirectory.path, withIntermediateDirectories: true, attributes: nil)
                
                print(fileManager.fileExists(atPath: audioDirectory.path, isDirectory: &isDir))
            } catch {
                print("fetchRecordings(): \(error)")
            }
        }
        let directoryContents = try! fileManager.contentsOfDirectory(at: audioDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = AudioRecord(fileURL: audio, createdAt: FileManager.getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
        
        objectWillChange.send(self)
    }
    
    func deleteRecording(urlsToDelete: [URL]) {
        for url in urlsToDelete {
            do {
                try FileManager.default.removeItem(at: url)
                print("deleted")
            } catch {
                print("File could not be deleted!")
            }
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            let level = self.audioRecorder.averagePower(forChannel: 0)
            self.soundSamples[self.currentSample] = Float(max(0.2, CGFloat(level) + 50) / 50.0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            
            self.objectWillChange.send(self)
        })
    }
    private func stopMonitoring() {
        timer?.invalidate()
    }
    private func recognizeSpeech(audioURL: URL, onCompleted: @escaping (String) -> Void) {
        let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "ru-RU"))
        let request = SFSpeechURLRecognitionRequest(url: audioURL)

        request.shouldReportPartialResults = true

        if (recognizer?.isAvailable)! {

            recognizer?.recognitionTask(with: request) { result, error in
                guard error == nil else { print("Error: \(error!)"); onCompleted(""); return }
                guard let result = result else { print("No result!"); onCompleted(""); return }

                print("Transcripted text: " + result.bestTranscription.formattedString)
                onCompleted(result.bestTranscription.formattedString)
            }
        } else {
            print("Device doesn't support speech recognition")
        }
    }
    private func delete(audioUrl: URL) {
        do {
            try FileManager.default.removeItem(at: audioUrl)
        } catch {
            print("moveAudioToPersistentDir(): \(error)")
        }
    }
    
    
    private var audioDirectory: URL {
        FileManager.getDocumentsDirectory().appendingPathComponent("AudioRecords")
    }
}
