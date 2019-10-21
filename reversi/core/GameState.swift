import Foundation

enum GameState {
    case notStarted
    case inProgress
    case complete
}

struct GameMove: Equatable {
    let coordinates: GameCoordinates
    let player: PlayerSide
}

struct Game: Equatable {
    let currentTurn: PlayerSide
    let moves: [GameMove]
    let errorMove: Optional<GameMove>
    let state: GameState
}
