import Flutter
import UIKit
import FirebaseCore
import workmanager_apple
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Flutter initializes Firebase with platform options when there is no
    // native configuration bundled in the app.
    if FirebaseApp.app() == nil,
       Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
      FirebaseApp.configure()
    }

    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        GeneratedPluginRegistrant.register(with: registry)
    }

    UNUserNotificationCenter.current().delegate = self

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let prayerChannel = FlutterMethodChannel(
      name: "com.mishkat_almasabih.app/prayer_notifications",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )

    prayerChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "schedulePrayerNotifications":
        if let jsonString = call.arguments as? String {
            self.schedulePrayerNotifications(jsonString: jsonString, replacingExisting: true)
            result(true)
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected JSON string", details: nil))
        }
      case "cancelPrayerNotifications":
        self.cancelPrayerNotifications()
        result(true)
      case "scheduleTestPrayerNotification":
        if let jsonString = call.arguments as? String {
            self.schedulePrayerNotifications(jsonString: jsonString, replacingExisting: false)
            result(true)
        } else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Expected JSON string", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
      if #available(iOS 14.0, *) {
          completionHandler([.banner, .list, .sound, .badge])
      } else {
          completionHandler([.alert, .sound, .badge])
      }
  }

  private func schedulePrayerNotifications(jsonString: String, replacingExisting: Bool) {
      guard let data = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let items = json["items"] as? [[String: Any]] else {
          return
      }

      let center = UNUserNotificationCenter.current()

      if replacingExisting {
          center.getPendingNotificationRequests { (requests) in
              let prayerIdentifiers = requests.map { $0.identifier }.filter { $0.hasPrefix("prayer_notification_") }
              center.removePendingNotificationRequests(withIdentifiers: prayerIdentifiers)
              self.addPrayerNotificationRequests(center: center, items: items)
          }
      } else {
          addPrayerNotificationRequests(center: center, items: items)
      }
  }

  private func addPrayerNotificationRequests(center: UNUserNotificationCenter, items: [[String: Any]]) {
      let now = Date()
      let futureItems = items.compactMap { item -> (item: [String: Any], date: Date)? in
          guard let date = fireDate(from: item["fireAtMillis"]) else {
              return nil
          }

          return date > now ? (item, date) : nil
      }
      .sorted { $0.date < $1.date }
      .prefix(64)

      for scheduledItem in futureItems {
          let item = scheduledItem.item
          let date = scheduledItem.date
          guard let id = item["id"] as? Int,
                let title = item["title"] as? String,
                let body = item["body"] as? String else {
              continue
          }

          let content = UNMutableNotificationContent()
          content.title = title
          content.body = body
          content.sound = UNNotificationSound.default
          
          let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
          let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
          
          let request = UNNotificationRequest(identifier: "prayer_notification_\(id)", content: content, trigger: trigger)
          
          center.add(request) { (error) in
              if let error = error {
                  print("Error scheduling notification: \(error)")
              }
          }
      }
  }

  private func fireDate(from value: Any?) -> Date? {
      if let milliseconds = value as? Int64 {
          return Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
      }

      if let milliseconds = value as? Int {
          return Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000.0)
      }

      if let milliseconds = value as? Double {
          return Date(timeIntervalSince1970: milliseconds / 1000.0)
      }

      if let number = value as? NSNumber {
          return Date(timeIntervalSince1970: number.doubleValue / 1000.0)
      }

      return nil
  }
  
  private func cancelPrayerNotifications() {
      let center = UNUserNotificationCenter.current()
      center.getPendingNotificationRequests { (requests) in
          let prayerIdentifiers = requests.map { $0.identifier }.filter { $0.hasPrefix("prayer_notification_") }
          center.removePendingNotificationRequests(withIdentifiers: prayerIdentifiers)
      }
  }
}
