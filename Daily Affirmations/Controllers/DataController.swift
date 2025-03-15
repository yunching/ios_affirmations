import CoreData
import Foundation

class DataController: ObservableObject {
    let container: NSPersistentContainer
    
    @Published var savedAffirmations: [AffirmationEntity] = []
    @Published var notificationSettings: NotificationSettingEntity?
    @Published var notificationTimes: [NotificationTimeEntity] = []
    
    init() {
        container = NSPersistentContainer(name: "DataModel")
        
        // Configure persistent store description to add better error handling
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
                print("Detailed error: \(error)")
                
                // Handle the error more gracefully in a production app
                fatalError("Unresolved Core Data error: \(error)")
            }
            
            print("Successfully loaded Core Data store: \(description.url?.absoluteString ?? "unknown")")
            
            DispatchQueue.main.async {
                self.fetchAffirmations()
                self.fetchNotificationSettings()
                self.fetchNotificationTimes()
                
                // Add sample data if no affirmations exist
                if self.savedAffirmations.isEmpty {
                    self.addSampleAffirmations()
                }
                
                // Initialize notification settings if not already set
                if self.notificationSettings == nil {
                    self.initializeNotificationSettings()
                }
            }
        }
    }
    
    func fetchAffirmations() {
        let request = NSFetchRequest<AffirmationEntity>(entityName: "AffirmationEntity")
        let sort = NSSortDescriptor(keyPath: \AffirmationEntity.createdAt, ascending: false)
        request.sortDescriptors = [sort]
        
        do {
            savedAffirmations = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching affirmations: \(error.localizedDescription)")
        }
    }
    
    func fetchNotificationSettings() {
        let request = NSFetchRequest<NotificationSettingEntity>(entityName: "NotificationSettingEntity")
        
        do {
            let results = try container.viewContext.fetch(request)
            notificationSettings = results.first
        } catch {
            print("Error fetching notification settings: \(error.localizedDescription)")
        }
    }
    
    func fetchNotificationTimes() {
        let request = NSFetchRequest<NotificationTimeEntity>(entityName: "NotificationTimeEntity")
        let sortByTime = NSSortDescriptor(keyPath: \NotificationTimeEntity.time, ascending: true)
        request.sortDescriptors = [sortByTime]
        
        do {
            notificationTimes = try container.viewContext.fetch(request)
        } catch {
            print("Error fetching notification times: \(error.localizedDescription)")
        }
    }
    
    func addSampleAffirmations() {
        for affirmation in Affirmation.sampleAffirmations {
            let newAffirmation = AffirmationEntity(context: container.viewContext)
            newAffirmation.id = affirmation.id
            newAffirmation.content = affirmation.content
            newAffirmation.isFavorite = affirmation.isFavorite
            newAffirmation.createdAt = affirmation.createdAt
        }
        
        saveContext()
    }
    
    func initializeNotificationSettings() {
        let settings = NotificationSettingEntity(context: container.viewContext)
        settings.id = UUID()
        settings.enabled = true
        settings.frequency = "daily"
        
        // Set default notification time to 8:00 AM
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        settings.time = Calendar.current.date(from: components)
        
        // Add default notification time entity
        if let defaultTime = settings.time {
            addNotificationTime(defaultTime, for: settings)
        }
        
        saveContext()
        notificationSettings = settings
        fetchNotificationTimes()
    }
    
    func addAffirmation(content: String) {
        let newAffirmation = AffirmationEntity(context: container.viewContext)
        newAffirmation.id = UUID()
        newAffirmation.content = content
        newAffirmation.createdAt = Date()
        newAffirmation.isFavorite = false
        
        saveContext()
        fetchAffirmations()
    }
    
    func toggleFavorite(affirmation: AffirmationEntity) {
        affirmation.isFavorite.toggle()
        saveContext()
        fetchAffirmations()
    }
    
    func deleteAffirmation(at offsets: IndexSet) {
        for index in offsets {
            let affirmation = savedAffirmations[index]
            container.viewContext.delete(affirmation)
        }
        
        saveContext()
        fetchAffirmations()
    }
    
    func updateNotificationSettings(enabled: Bool, frequency: String, time: Date) {
        if let settings = notificationSettings {
            settings.enabled = enabled
            settings.frequency = frequency
            settings.time = time
            
            saveContext()
        }
    }
    
    func updateNotificationSettings(enabled: Bool, frequency: String, times: [Date]) {
        if let settings = notificationSettings {
            settings.enabled = enabled
            settings.frequency = frequency
            
            // Keep the first time in the legacy 'time' field for backward compatibility
            if let firstTime = times.first {
                settings.time = firstTime
            }
            
            // Clear existing notification times
            if let existingTimes = settings.times as? Set<NotificationTimeEntity> {
                for existingTime in existingTimes {
                    container.viewContext.delete(existingTime)
                }
            }
            
            // Add new notification times
            for time in times {
                addNotificationTime(time, for: settings)
            }
            
            saveContext()
            fetchNotificationTimes()
        }
    }
    
    func addNotificationTime(_ time: Date, for settings: NotificationSettingEntity) {
        let timeEntity = NotificationTimeEntity(context: container.viewContext)
        timeEntity.id = UUID()
        timeEntity.time = time
        timeEntity.setting = settings
    }
    
    func addNotificationTime(_ time: Date) {
        if let settings = notificationSettings {
            addNotificationTime(time, for: settings)
            saveContext()
            fetchNotificationTimes()
        }
    }
    
    func removeNotificationTime(_ timeEntity: NotificationTimeEntity) {
        container.viewContext.delete(timeEntity)
        saveContext()
        fetchNotificationTimes()
    }
    
    func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}
