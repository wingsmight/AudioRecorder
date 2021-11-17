import Foundation
import SwiftUI
import AVFoundation
import Combine
import Speech

class AudioRecorder: ObservableObject {
    let MAX_SILENCE_DURATION_SECONDS: Double = 10
    let LIMIT_RECORD_DURATION_SECONDS: Double = 60 * 3 // 3 mins
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var numberOfSamples: Int
    private var timer: Timer?
    private var currentSample: Int = 0
    private var audioRecorder: AVAudioRecorder!
    private var autoStop: DispatchWorkItem?
    private var stopAtLimit: DispatchWorkItem?
    
    @AppStorage("recordings") private var recordings: [AudioRecord] = []
    @Published public var recording = false;
    @Published public var soundSamples: [Float] = []
    
    public static var isRecording: Bool = false
    
    
    public init(numberOfSamples: Int = 3) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: self.numberOfSamples)
        self.recordings = []
        
        fetchRecordings()
        
        do {
            try! AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
            try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try! AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up recording session")
        }
    }
    
    
    func startRecording() {
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
            
            stopAtLimit = DispatchWorkItem(block: {
                print("Audio Recorder was stoped at limit")
                
                self.stopRecording()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + LIMIT_RECORD_DURATION_SECONDS, execute: stopAtLimit!)
            
            resetAutoStop()
            
            recording = true
            AudioRecorder.isRecording = recording
        } catch {
            print("Could not start recording")
        }
    }
    
    func resetAutoStop() {
        autoStop?.cancel()
        autoStop = DispatchWorkItem(block: {
            print("Audio Recorder was auto stoped")
            
            self.stopRecording()
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + MAX_SILENCE_DURATION_SECONDS, execute: autoStop!)
    }
    func stopRecording() {
        if !recording {
            return
        }
        
        print("Audio Recorder was manually stopped")
        
        autoStop?.cancel()
        stopAtLimit?.cancel()
        
        audioRecorder.stop()
        
        fetchRecordings()
        
        recording = false
        AudioRecorder.isRecording = recording
        
        stopMonitoring()
        
        let lastAudioRecord: AudioRecord! = recordings.first
        uploadRecord(currentUserId: AppAuth().currentUser!.uid, audio: lastAudioRecord.fileURL) { (result) in
            switch result {
            case .success(_):
                print("Audio Record was uploaded successfully")
                break
            case .failure(_):
                print("Audio Record was not uploaded")
                break
            }
        }
    }
    func fetchRecordings() {
        recordings.removeAll()
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        if !fileManager.fileExists(atPath: audioDirectory.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: audioDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("fetchRecordings(): \(error)")
            }
        }
        let directoryContents = try! fileManager.contentsOfDirectory(at: audioDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = AudioRecord(fileURL: audio, createdAt: FileManager.getCreationDate(for: audio))
            recordings.append(recording)
        }
        
        recordings.sort(by: { $1.createdAt.compare($0.createdAt) == .orderedAscending})
    }
    
    public static func deleteRecordings(urlsToDelete: [URL]) {
        for url in urlsToDelete {
            deleteRecording(url: url)
        }
    }
    public static func deleteRecording(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("\(url) was deleted")
        } catch {
            print("\(url) File could not be deleted!")
        }
    }
    
    private func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.audioRecorder.updateMeters()
            let level = self.audioRecorder.averagePower(forChannel: 0)
            self.soundSamples[self.currentSample] = Float(max(0.2, CGFloat(level) + 50) / 50.0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
        })
    }
    private func stopMonitoring() {
        timer?.invalidate()
    }
    private var audioDirectory: URL {
        FileManager.getDocumentsDirectory().appendingPathComponent("AudioRecords")
    }
}
