import Foundation

func initialState() -> Game {
    return Game(
        currentTurn: .black,
        moves: [],
        errorMove: .none,
        state: .notStarted
    )
}

func updateState(_ state: Game, _ event: Event) -> Game {
    switch event {
    case .gameStarted:
        return Game(
        currentTurn: state.currentTurn,
        moves: [],
        errorMove: .none,
        state: .inProgress
        )
    case let .changePlayer(side):
        return Game(
            currentTurn: side,
            moves: state.moves,
            errorMove: state.errorMove,
            state: state.state
        )
    case let .madeMove(move):
        var updatedMoves = state.moves
        updatedMoves.append(move)
        
        return Game(
            currentTurn: state.currentTurn,
            moves: updatedMoves,
            errorMove: .none,
            state: .inProgress
        )
    case let .flip(coordinates):
        let updatedMoves = state.moves.map { (move: GameMove) -> GameMove in
            if (coordinates == move.coordinates) {
                return GameMove(
                    coordinates: move.coordinates,
                    player: move.player.opposite()
                )
            } else {
                return move
            }
        }
        
        return Game(
            currentTurn: state.currentTurn,
            moves: updatedMoves,
            errorMove: .none,
            state: state.state
        )
    case let .moveError(_, move):
        return Game(
            currentTurn: state.currentTurn,
            moves: state.moves,
            errorMove: move,
            state: state.state
        )
    case .gameAlreadyInProgressError: return state
    }
}
