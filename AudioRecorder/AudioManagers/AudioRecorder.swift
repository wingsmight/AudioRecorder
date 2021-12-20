import Foundation
import SwiftUI
import AVFoundation
import Combine
import Speech
import CoreLocation

class AudioRecorder: ObservableObject {
    let MAX_SILENCE_DURATION_SECONDS: Double = 10
    let LIMIT_RECORD_DURATION_SECONDS: Double = 60 * 3 // 3 mins
    let MAX_RECORD_COUNT = 50
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var numberOfSamples: Int
    private var timer: Timer?
    private var currentSample: Int = 0
    private var audioRecorder: AVAudioRecorder!
    private var autoStop: DispatchWorkItem?
    private var stopAtLimit: DispatchWorkItem?
    private var lastLocation: CLLocation?
    private var locationManager = LocationManager()
    private var lastRecordUrl: URL!
    
    @AppStorage("recordings") private var recordings: [AudioRecord] = []
    @Published public var isRecording = false;
    @Published public var soundSamples: [Float] = []
    @AppStorage("doNotDisturbStartTime") private var doNotDisturbStartTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
    @AppStorage("doNotDisturbFinishTime") private var doNotDisturbFinishTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    
    
    public init(numberOfSamples: Int = 3) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: self.numberOfSamples)
        
        do {
            try AVAudioSession.sharedInstance().setAllowHapticsAndSystemSoundsDuringRecording(true)
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, options: [.defaultToSpeaker, .mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up recording session")
        }
        
        let fileManager = FileManager.default
        var isDir : ObjCBool = true
        if !fileManager.fileExists(atPath: audioDirectory.path, isDirectory: &isDir) {
            do {
                try fileManager.createDirectory(atPath: audioDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("init(): \(error)")
            }
        }
    }
    
    
    func startRecording() {
        print("isRecordingAvailable = \(isRecordingAvailable())")
        if !isRecordingAvailable() {
            return;
        }
        
        lastRecordUrl = audioDirectory.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: lastRecordUrl, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
            startMonitoring()
            
            stopAtLimit = DispatchWorkItem(block: {
                print("Audio Recorder was stoped at limit")
                
                self.stopRecording()
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + LIMIT_RECORD_DURATION_SECONDS, execute: stopAtLimit!)
            
            resetAutoStop()
            
            isRecording = true
            
            locationManager.requestLocation()
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
        if !isRecording {
            return
        }
        
        print("Audio Recorder was manually stopped")
        
        autoStop?.cancel()
        stopAtLimit?.cancel()
        
        audioRecorder.stop()
        
        lastLocation = locationManager.lastRequestedLocation
        let lastAudioRecord = AudioRecord(fileURL: lastRecordUrl, createdAt: FileManager.getCreationDate(for: lastRecordUrl), location: lastLocation)
        recordings.append(lastAudioRecord)
        sortRecords()
        checkForRecordLimit()
        
        isRecording = false
        
        stopMonitoring()
        
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
    func sortRecords() {
        recordings.sort(by: { $1.createdAt.compare($0.createdAt) == .orderedAscending})
    }
    func checkForRecordLimit() {
        while recordings.count > MAX_RECORD_COUNT {
            let lastRecord = recordings.removeLast()
            _ = try? FileManager.default.removeItem(at: lastRecord.fileURL)
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
    func isRecordingAvailable() -> Bool {
        let now = Date();
        
        if doNotDisturbStartTime.time <= doNotDisturbFinishTime.time {
            return !now.isTimeBetweenInterval(intervalStart: doNotDisturbStartTime, intervalFinish: doNotDisturbFinishTime)
        } else {
            return now.isTimeBetweenInterval(intervalStart: doNotDisturbFinishTime, intervalFinish: doNotDisturbStartTime)
        }
    }
}
