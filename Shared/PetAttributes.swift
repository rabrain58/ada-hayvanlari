import ActivityKit
import Foundation

struct PetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var position: Double      // 0 = sol, 1 = sag
        var facingRight: Bool
        var frame: Int            // yurume karesi (0 veya 1)
    }
    var petKind: String           // "cat", "dog", "bunny"
}
