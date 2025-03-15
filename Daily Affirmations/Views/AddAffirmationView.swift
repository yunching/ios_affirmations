import SwiftUI

struct AddAffirmationView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @State private var affirmationText = ""
    @State private var showingConfirmation = false
    @State private var showNotificationOptions = false
    @State private var scheduleNotification = false
    @State private var notificationDate = Date()
    
    private let characterLimit = 150
    private let placeholderText = "Enter your affirmation here..."
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create Your Affirmation")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.purple)
                        
                        Text("Positive affirmations can help shift your mindset and improve your day. Add one that resonates with you.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                        
                        ZStack(alignment: .topLeading) {
                            if affirmationText.isEmpty {
                                Text(placeholderText)
                                    .foregroundColor(.gray.opacity(0.8))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 12)
                            }
                            
                            TextEditor(text: $affirmationText)
                                .frame(minHeight: 100)
                                .padding(4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.purple.opacity(0.5), lineWidth: 1)
                                )
                                .opacity(affirmationText.isEmpty ? 0.85 : 1)
                        }
                        .frame(minHeight: 100)
                        
                        Text("\(affirmationText.count)/\(characterLimit) characters")
                            .font(.caption)
                            .foregroundColor(affirmationText.count > characterLimit ? .red : .secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Toggle(isOn: $scheduleNotification) {
                            Text("Schedule a notification for this affirmation")
                                .foregroundColor(.primary)
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .purple))
                        .padding(.vertical, 8)
                        
                        if scheduleNotification {
                            DatePicker("Notification Time", selection: $notificationDate, displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(DefaultDatePickerStyle())
                                .padding(.bottom, 10)
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: saveAffirmation) {
                            Text("Save Affirmation")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isFormValid ? Color.purple : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!isFormValid)
                        .padding(.vertical)
                        
                        // Inspirational quotes/examples
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Need inspiration? Try one of these:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            AffirmationExampleCard(text: "I am becoming the best version of myself")
                            AffirmationExampleCard(text: "I trust my intuition and follow my inner wisdom")
                            AffirmationExampleCard(text: "I am worthy of great things in life")
                        }
                        .padding(.vertical)
                    }
                    .padding()
                }
                .alert("Affirmation Created", isPresented: $showingConfirmation) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Your affirmation has been saved successfully.")
                }
                .navigationBarTitle("Add New", displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    affirmationText = ""
                    scheduleNotification = false
                }) {
                    Text("Clear")
                        .foregroundColor(.purple)
                })
            }
        }
    }
    
    private var isFormValid: Bool {
        !affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        affirmationText.count <= characterLimit
    }
    
    private func saveAffirmation() {
        guard isFormValid else { return }
        
        dataController.addAffirmation(content: affirmationText)
        
        if scheduleNotification {
            if let lastAffirmation = dataController.savedAffirmations.first,
               let content = lastAffirmation.content {
                let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                NotificationManager.shared.scheduleCustomNotification(content: content, dateComponents: components)
            }
        }
        
        // Reset form and show confirmation
        affirmationText = ""
        scheduleNotification = false
        showingConfirmation = true
        
        // Give haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct AffirmationExampleCard: View {
    let text: String
    
    var body: some View {
        Button(action: {
            // We'll need to use the parent's state, so this is just UI for now
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }) {
            Text(text)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddAffirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AddAffirmationView()
    }
}
