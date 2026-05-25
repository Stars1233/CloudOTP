import Cocoa
import FlutterMacOS
import UserNotifications

public class LocalNotifierOverride: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {
    var channel: FlutterMethodChannel!

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "local_notifier", binaryMessenger: registrar.messenger)
        let instance = LocalNotifierOverride()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        UNUserNotificationCenter.current().delegate = instance
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "notify":
            notify(call, result: result)
        case "close":
            close(call, result: result)
        case "checkPermission":
            checkPermission(result: result)
        case "openNotificationSettings":
            openNotificationSettings(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func checkPermission(result: @escaping FlutterResult) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized:
                    result("authorized")
                case .denied:
                    result("denied")
                case .notDetermined:
                    result("notDetermined")
                case .provisional:
                    result("provisional")
                case .ephemeral:
                    result("ephemeral")
                @unknown default:
                    result("unknown")
                }
            }
        }
    }

    public func openNotificationSettings(result: @escaping FlutterResult) {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
            NSWorkspace.shared.open(url)
        }
        result(true)
    }

    public func notify(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing identifier", details: nil))
            return
        }

        let title = args["title"] as? String ?? ""
        let subtitle = args["subtitle"] as? String ?? ""
        let body = args["body"] as? String ?? ""

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                result(FlutterError(code: "NOTIFY_ERROR", message: error.localizedDescription, details: nil))
            } else {
                DispatchQueue.main.async {
                    self.channel.invokeMethod("onLocalNotificationShow", arguments: ["notificationId": identifier])
                }
                result(true)
            }
        }
    }

    public func close(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["identifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing identifier", details: nil))
            return
        }

        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
        channel.invokeMethod("onLocalNotificationClose", arguments: ["notificationId": identifier])
        result(true)
    }

    // Show notifications even when app is in foreground
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(macOS 11.0, *) {
            completionHandler([.banner, .sound])
        } else {
            completionHandler([.alert, .sound])
        }
    }

    // Handle notification click
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        channel.invokeMethod("onLocalNotificationClick", arguments: ["notificationId": identifier])
        completionHandler()
    }
}
