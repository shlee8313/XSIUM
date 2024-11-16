import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}



// import UIKit
// import Flutter

// @UIApplicationMain
// @objc class AppDelegate: FlutterAppDelegate {

//     private let channelName = "com.example.xsium_chat/app_lifecycle"
//     private var isLoginInProgress = false

//     override func application(
//         _ application: UIApplication,
//         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//     ) -> Bool {
//         let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
//         let appLifecycleChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)

//         appLifecycleChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
//             guard let self = self else { return }

//             switch call.method {
//             case "openXummLogin":
//                 if let deepLink = call.arguments as? String {
//                     self.handleXummLogin(deepLink: deepLink, result: result)
//                 } else {
//                     result(FlutterError(code: "INVALID_ARGUMENT", message: "Deep link is required", details: nil))
//                 }
//             case "isXummInstalled":
//                 result(self.isXummInstalled())
//             case "moveToBackground":
//                 self.moveToBackground(result: result)
//             case "bringToFront":
//                 self.bringToFront(result: result)
//             default:
//                 result(FlutterMethodNotImplemented)
//             }
//         }

//         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//     }

//     /// Opens XUMM via a deep link, similar to Android functionality
//     private func handleXummLogin(deepLink: String, result: FlutterResult) {
//         guard let url = URL(string: deepLink) else {
//             result(FlutterError(code: "INVALID_URL", message: "Invalid XUMM deep link URL", details: nil))
//             return
//         }

//         if isNetworkAvailable() {
//             if UIApplication.shared.canOpenURL(url) {
//                 UIApplication.shared.open(url, options: [:]) { success in
//                     if success {
//                         self.isLoginInProgress = true
//                         result(true)
//                     } else {
//                         result(FlutterError(code: "UNABLE_TO_OPEN", message: "Failed to open XUMM", details: nil))
//                     }
//                 }
//             } else {
//                 result(FlutterError(code: "XUMM_NOT_INSTALLED", message: "XUMM app is not installed", details: nil))
//             }
//         } else {
//             result(FlutterError(code: "NETWORK_ERROR", message: "Please check your network connection", details: nil))
//         }
//     }

//     /// Checks if XUMM is installed
//     private func isXummInstalled() -> Bool {
//         guard let url = URL(string: "xumm://") else { return false }
//         return UIApplication.shared.canOpenURL(url)
//     }

//     /// Simulates moving the app to the background (limited in iOS)
//     private func moveToBackground(result: FlutterResult) {
//         // iOS doesn’t support programmatic backgrounding of the app like Android.
//         // Notify Flutter side; alternative functionality could be added if necessary.
//         result(true)
//     }

//     /// Brings the app to the front by bringing the app’s main view controller into focus
//     private func bringToFront(result: FlutterResult) {
//         // iOS does not have an exact equivalent for bringing an app to the front.
//         result(true)
//     }

//     /// Checks if the network is available
//     private func isNetworkAvailable() -> Bool {
//         let reachability = Reachability() // Assumes Reachability class is available for network checking
//         return reachability.connection != .unavailable
//     }

//     /// Handles callback from XUMM after a successful login
//     override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
//         if url.scheme == "xumm" && url.host == "success" {
//             handleLoginSuccess()
//             return true
//         }
//         return false
//     }

//     private func handleLoginSuccess() {
//         isLoginInProgress = false
//         if let flutterViewController = window?.rootViewController as? FlutterViewController {
//             let appLifecycleChannel = FlutterMethodChannel(name: channelName, binaryMessenger: flutterViewController.binaryMessenger)
//             appLifecycleChannel.invokeMethod("onLoginSuccess", arguments: nil)
//         }
//     }
// }