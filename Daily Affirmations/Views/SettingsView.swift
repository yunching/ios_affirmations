import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var notificationsEnabled = true
    @State private var selectedFrequency = "daily"
    @State private var notificationTime = Date()
    @State private var notificationTimes: [Date] = []
    @State private var showingAlert = false
    @State private var showingTimePickerSheet = false
    @State private var newTime = Date()
    
    let frequencies = ["daily", "weekdays", "weekly"]
    let frequencyNames = ["Daily", "Weekdays Only", "Weekly"]
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                Form {
                    Section(header: Text("Notification Settings")) {
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                        
                        if notificationsEnabled {
                            Picker("Frequency", selection: $selectedFrequency) {
                                ForEach(0..<frequencies.count, id: \.self) { index in
                                    Text(frequencyNames[index]).tag(frequencies[index])
                                }
                            }
                            
                            Section(header: Text("Notification Times")) {
                                ForEach(notificationTimes, id: \.self) { time in
                                    HStack {
                                        Text(timeFormatter.string(from: time))
                                        Spacer()
                                        Button(action: {
                                            if let index = notificationTimes.firstIndex(of: time) {
                                                notificationTimes.remove(at: index)
                                            }
                                        }) {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                
                                Button(action: {
                                    // Set newTime to a reasonable default (current time rounded to next 30 min)
                                    let calendar = Calendar.current
                                    let hour = calendar.component(.hour, from: Date())
                                    let minute = calendar.component(.minute, from: Date())
                                    let roundedMinute = minute >= 30 ? 0 : 30
                                    let roundedHour = minute >= 30 ? (hour + 1) % 24 : hour
                                    
                                    var components = DateComponents()
                                    components.hour = roundedHour
                                    components.minute = roundedMinute
                                    newTime = calendar.date(from: components) ?? Date()
                                    showingTimePickerSheet = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.purple)
                                        Text("Add New Time")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .disabled(notificationTimes.count >= NotificationManager.maxDailyNotifications)
                                
                                if notificationTimes.count >= NotificationManager.maxDailyNotifications {
                                    Text("Maximum of \(NotificationManager.maxDailyNotifications) notification times allowed")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        NavigationLink(destination: AboutView()) {
                            Text("About This App")
                        }
                        
                        Button(action: {
                            let url = URL(string: "mailto:support@example.com")!
                            UIApplication.shared.open(url)
                        }) {
                            Text("Contact Support")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Section {
                        Button(action: saveSettings) {
                            Text("Save Settings")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 10)
                                .background(Color.purple)
                                .cornerRadius(8)
                        }
                    }
                }
                .onAppear(perform: loadSettings)
                .alert("Settings Saved", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("Your notification settings have been updated.")
                }
                .sheet(isPresented: $showingTimePickerSheet) {
                    TimePickerSheet(isPresented: $showingTimePickerSheet, selectedTime: $newTime, onSave: { time in
                        if !notificationTimes.contains(time) {
                            notificationTimes.append(time)
                            notificationTimes.sort()
                        }
                    })
                }
                .navigationTitle("Settings")
            }
        }
    }
    
    // Time formatter for displaying times
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    func loadSettings() {
        if let settings = dataController.notificationSettings {
            notificationsEnabled = settings.enabled
            selectedFrequency = settings.frequency ?? "daily"
            
            // Load the legacy time first to ensure backward compatibility
            if let time = settings.time {
                notificationTime = time
            }
            
            // Load all notification times
            notificationTimes = dataController.notificationTimes.compactMap { $0.time }
            
            // If no notification times are set but we have a legacy time, add it to the times array
            if notificationTimes.isEmpty, let time = settings.time {
                notificationTimes = [time]
            }
        }
    }
    
    func saveSettings() {
        // Ensure we have at least one notification time
        if notificationTimes.isEmpty && notificationsEnabled {
            notificationTimes = [notificationTime] // Use the legacy time if no times are set
        }
        
        // Save settings with multiple times
        dataController.updateNotificationSettings(
            enabled: notificationsEnabled,
            frequency: selectedFrequency,
            times: notificationTimes
        )
        
        if notificationsEnabled {
            NotificationManager.shared.scheduleNotifications(
                for: dataController.savedAffirmations,
                frequency: selectedFrequency,
                times: notificationTimes
            )
        } else {
            // Remove pending notifications if disabled
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        // Show confirmation
        showingAlert = true
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct AboutView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]),
                          startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.purple)
                        .padding(.top, 40)
                    
                    Text("Daily Affirmations")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Divider()
                        .padding(.horizontal, 50)
                    
                    Text("About This App")
                        .font(.headline)
                        .padding(.top)
                    
                    Text("Daily Affirmations helps you stay positive with regular affirmations that boost your mindset. Set custom notifications to remind yourself of positive thoughts throughout your day.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                    Text("© 2025 Daily Affirmations")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .padding()
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimePickerSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedTime: Date
    var onSave: (Date) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
            }
            .navigationTitle("Add Notification Time")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    onSave(selectedTime)
                    isPresented = false
                }
            )
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
