import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    // Maximum number of daily notifications allowed
    static let maxDailyNotifications = 5
    
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
    
    func scheduleNotifications(for affirmations: [AffirmationEntity], frequency: String, times: [Date]) {
        // Remove any existing notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        guard !affirmations.isEmpty else { return }
        
        // Create notifications for each affirmation based on frequency
        let shuffledAffirmations = affirmations.shuffled()
        
        // For each time, schedule appropriate notifications
        for time in times {
            // Extract just the time components
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            
            switch frequency {
            case "daily":
                // Use a different affirmation for each time slot if possible
                let index = min(times.firstIndex(of: time) ?? 0, shuffledAffirmations.count - 1)
                scheduleDailyNotification(affirmation: shuffledAffirmations[index], at: timeComponents, timeIndex: times.firstIndex(of: time) ?? 0)
            case "weekdays":
                scheduleWeekdayNotifications(affirmations: shuffledAffirmations, at: timeComponents, timeIndex: times.firstIndex(of: time) ?? 0)
            case "weekly":
                scheduleWeeklyNotification(affirmation: shuffledAffirmations[0], at: timeComponents, timeIndex: times.firstIndex(of: time) ?? 0)
            default:
                break
            }
        }
    }
    
    private func scheduleDailyNotification(affirmation: AffirmationEntity, at time: DateComponents, timeIndex: Int) {
        guard let content = affirmation.content else { return }

        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Your Daily Affirmation"
        notificationContent.body = content
        notificationContent.sound = .default
        
        let components = time
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-affirmation-\(timeIndex)", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleWeekdayNotifications(affirmations: [AffirmationEntity], at time: DateComponents, timeIndex: Int) {
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
            let request = UNNotificationRequest(identifier: "affirmation-\(weekday)-\(timeIndex)", content: notificationContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func scheduleWeeklyNotification(affirmation: AffirmationEntity, at time: DateComponents, timeIndex: Int) {
        guard let content = affirmation.content else { return }
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "Your Weekly Affirmation"
        notificationContent.body = content
        notificationContent.sound = .default
        
        var components = time
        components.weekday = 1  // Sunday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly-affirmation-\(timeIndex)", content: notificationContent, trigger: trigger)
        
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
