import Flutter
import GoogleMaps
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Chave do Google Maps: ios/Flutter/Secrets.xcconfig (ignorado pelo Git).
    if let chave = Bundle.main.object(forInfoDictionaryKey: "MAPS_API_KEY") as? String, !chave.isEmpty {
      GMSServices.provideAPIKey(chave)
    }
    // Lembretes de coleta: mostra a notificação mesmo com o app aberto.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
