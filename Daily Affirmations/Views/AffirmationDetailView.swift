import SwiftUI

struct AffirmationDetailView: View {
    var affirmation: AffirmationEntity
    @EnvironmentObject var dataController: DataController
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.white]),
                          startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Affirmation card
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    
                    VStack(spacing: 20) {
                        Image(systemName: "quote.opening")
                            .font(.system(size: 40))
                            .foregroundColor(.purple.opacity(0.7))
                        
                        Text(affirmation.content ?? "")
                            .font(.title2)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 30)
                        
                        Image(systemName: "quote.closing")
                            .font(.system(size: 40))
                            .foregroundColor(.purple.opacity(0.7))
                    }
                    .padding(.vertical, 40)
                }
                .frame(height: 300)
                
                // Action buttons
                HStack(spacing: 40) {
                    Button(action: {
                        dataController.toggleFavorite(affirmation: affirmation)
                    }) {
                        VStack {
                            Image(systemName: affirmation.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 26))
                                .foregroundColor(affirmation.isFavorite ? .red : .gray)
                            
                            Text("Favorite")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        VStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 26))
                                .foregroundColor(.blue)
                            
                            Text("Share")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        scheduleCustomNotification()
                    }) {
                        VStack {
                            Image(systemName: "bell")
                                .font(.system(size: 26))
                                .foregroundColor(.orange)
                            
                            Text("Remind")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .sheet(isPresented: $showingShareSheet) {
            if let content = affirmation.content {
                ShareSheet(activityItems: [content])
            }
        }
    }
    
    func scheduleCustomNotification() {
        // Schedule a one-time notification for this specific affirmation
        if let content = affirmation.content {
            // Set notification for 1 hour from now
            let hourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: hourFromNow)
            
            NotificationManager.shared.scheduleCustomNotification(content: content, dateComponents: components)
            
            // Show confirmation to user
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// Simple ShareSheet implementation
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Nothing to do here
    }
}
