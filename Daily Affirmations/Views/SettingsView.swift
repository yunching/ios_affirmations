import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var dataController: DataController
    @State private var notificationsEnabled = true
    @State private var selectedFrequency = "daily"
    @State private var notificationTime = Date()
    @State private var showingAlert = false
    
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
                            
                            DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
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
                .navigationTitle("Settings")
            }
        }
    }
    
    func loadSettings() {
        if let settings = dataController.notificationSettings {
            notificationsEnabled = settings.enabled
            selectedFrequency = settings.frequency ?? "daily"
            if let time = settings.time {
                notificationTime = time
            }
        }
    }
    
    func saveSettings() {
        dataController.updateNotificationSettings(
            enabled: notificationsEnabled,
            frequency: selectedFrequency,
            time: notificationTime
        )
        
        if notificationsEnabled {
            NotificationManager.shared.scheduleNotifications(
                for: dataController.savedAffirmations,
                frequency: selectedFrequency,
                time: notificationTime
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
