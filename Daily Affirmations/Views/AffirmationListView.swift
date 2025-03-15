import SwiftUI

struct AffirmationListView: View {
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var dataController: DataController
    @State private var showingDetailView = false
    @State private var selectedAffirmation: AffirmationEntity?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.purple.opacity(0.2), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    if dataController.savedAffirmations.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            
                            Text("No affirmations yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.purple)
                            
                            Text("Add your first affirmation from the 'Add New' tab")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        .padding()
                    } else {
                        List {
                            ForEach(dataController.savedAffirmations, id: \.id) { affirmation in
                                AffirmationRow(affirmation: affirmation)
                                    .onTapGesture {
                                        selectedAffirmation = affirmation
                                        showingDetailView = true
                                    }
                            }
                            .onDelete(perform: dataController.deleteAffirmation)
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
                .navigationTitle("Daily Affirmations")
                .sheet(isPresented: $showingDetailView) {
                    if let affirmation = selectedAffirmation {
                        AffirmationDetailView(affirmation: affirmation)
                            .environmentObject(dataController)
                    }
                }
            }
        }
    }
}

struct AffirmationRow: View {
    var affirmation: AffirmationEntity
    @EnvironmentObject var dataController: DataController
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(affirmation.content ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.vertical, 5)
                
                if let createdAt = affirmation.createdAt {
                    Text(formatDate(createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: {
                dataController.toggleFavorite(affirmation: affirmation)
            }) {
                Image(systemName: affirmation.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(affirmation.isFavorite ? .red : .gray)
                    .font(.system(size: 22))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 5)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct AffirmationListView_Previews: PreviewProvider {
    static var previews: some View {
        AffirmationListView()
    }
}
