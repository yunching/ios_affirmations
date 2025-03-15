import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(for affirmations: [AffirmationEntity], frequency: String, time: Date) {
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard !affirmations.isEmpty else { return }
        
        // Extract just the time components
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create notifications for each affirmation based on frequency
        let shuffledAffirmations = affirmations.shuffled()
        
        switch frequency {
        case "daily":
            scheduleDailyNotification(affirmation: shuffledAffirmations[0], at: timeComponents)
        case "weekdays":
            scheduleWeekdayNotifications(affirmations: shuffledAffirmations, at: timeComponents)
        case "weekly":
            scheduleWeeklyNotification(affirmation: shuffledAffirmations[0], at: timeComponents)
        default:
            break
        }
    }
    
    private func scheduleDailyNotification(affirmation: AffirmationEntity, at time: DateComponents) {
        guard let content = affirmation.content else { return }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Your Daily Affirmation"
        notificationContent.body = content
        notificationContent.sound = .default
        
        let components = time
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleWeekdayNotifications(affirmations: [AffirmationEntity], at time: DateComponents) {
        // Schedule for Monday through Friday (1-5)
        for weekday in 2...6 {
            let index = (weekday - 2) % affirmations.count
            guard let content = affirmations[index].content else { continue }
            
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Your Daily Affirmation"
            notificationContent.body = content
            notificationContent.sound = .default
            
            var components = time
            components.weekday = weekday
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "affirmation-\(weekday)", content: notificationContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleWeeklyNotification(affirmation: AffirmationEntity, at time: DateComponents) {
        guard let content = affirmation.content else { return }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Your Weekly Affirmation"
        notificationContent.body = content
        notificationContent.sound = .default
        
        var components = time
        components.weekday = 1  // Sunday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-affirmation", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleCustomNotification(content: String, dateComponents: DateComponents, repeats: Bool = false) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Custom Affirmation"
        notificationContent.body = content
        notificationContent.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling custom notification: \(error.localizedDescription)")
            }
        }
    }
}
