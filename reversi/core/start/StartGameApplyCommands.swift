import Foundation

func startGameApplyCommands(
    _ state: StartGameProjection,
    _ command: Command
) -> [Event] {
        switch (command, state.gameState) {
        case (.newGame, .notStarted), (.newGame, .complete):
            return [
                .gameStarted,
                .madeMove(move: GameMove(coordinates: GameCoordinates(x: .one, y: .one), player: .black)),
                .madeMove(move: GameMove(coordinates: GameCoordinates(x: .m_one, y: .m_one), player: .black)),
                .madeMove(move: GameMove(coordinates: GameCoordinates(x: .m_one, y: .one), player: .white)),
                .madeMove(move: GameMove(coordinates: GameCoordinates(x: .one, y: .m_one), player: .white)),
                .changePlayer(side: .black)
            ]
        case (.newGame, _):
            return [.gameAlreadyInProgressError]
        case (.makeMove(let move), _): return []
    }
}
