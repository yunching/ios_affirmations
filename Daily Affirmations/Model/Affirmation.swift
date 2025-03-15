import Foundation
import SwiftUI

struct Affirmation: Identifiable, Hashable {
    let id: UUID
    let content: String
    var isFavorite: Bool
    let createdAt: Date
    
    init(id: UUID = UUID(), content: String, isFavorite: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
    
    static let sampleAffirmations = [
        Affirmation(content: "I am capable of achieving anything I set my mind to."),
        Affirmation(content: "I am deserving of love and happiness."),
        Affirmation(content: "I choose to be positive and radiate positivity."),
        Affirmation(content: "My potential is limitless, and I can do amazing things."),
        Affirmation(content: "I am grateful for all the abundance in my life."),
        Affirmation(content: "I am in control of my thoughts and emotions."),
        Affirmation(content: "I trust my intuition and make wise decisions."),
        Affirmation(content: "Every day I am becoming a better version of myself."),
        Affirmation(content: "I am surrounded by love and support."),
        Affirmation(content: "I radiate confidence, positivity, and strength.")
    ]
}
