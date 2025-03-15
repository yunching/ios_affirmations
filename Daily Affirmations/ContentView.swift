import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            AffirmationListView()
                .tabItem {
                    Label("Affirmations", systemImage: "heart.fill")
                }
                .tag(0)
            
            AddAffirmationView()
                .tabItem {
                    Label("Add New", systemImage: "plus.circle")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}
