import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    do {
      let session = AVAudioSession.sharedInstance()
      try session.setCategory(.playback)
      try session.setActive(true)
    } catch {
      print("Failed to set audio session category: \(error)")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
