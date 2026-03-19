import SwiftUI

struct GamePlayer: Identifiable, Codable {
    let player: Player
    var score: Int = 0
    var roundWins: Int = 0
    var busts: Int = 0

    var id: UUID { player.id }
    var name: String { player.name }
    var emoji: String { player.emoji }
    var themeColor: Color { player.themeColor }

    enum CodingKeys: String, CodingKey {
        case player, score, roundWins, busts
    }
}
