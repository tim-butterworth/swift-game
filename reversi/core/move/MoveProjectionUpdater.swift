import Foundation

func moveProjectionUpdater(
    _ state: MakeMoveProjection,
    _ events: [Event]
) -> MakeMoveProjection {
    return events.reduce(state, handleTheEvent)
}

func handleTheEvent(accume: MakeMoveProjection, element: Event) -> MakeMoveProjection {
    switch element {
    case let .madeMove(move):
        var updateableMoves = accume.moves
        updateableMoves.append(move)
        
        var updatableBoard = accume.board
        updatableBoard[move.coordinates.x.rawValue][move.coordinates.y.rawValue] = .some(move.player)
        
        return MakeMoveProjection(
            moves: updateableMoves,
            side: move.player,
            board: updatableBoard
        )
    case let .flip(coordinates):
        var board = accume.board
        let x = coordinates.x.rawValue
        let y = coordinates.y.rawValue
        
        let originalSide = board[x][y]
        
        board[x][y] = originalSide.map { $0.opposite() }
        
        return MakeMoveProjection(
            moves: accume.moves,
            side: accume.side,
            board: board
        )
    case let .changePlayer(side):
        return MakeMoveProjection(
            moves: accume.moves,
            side: side,
            board: accume.board
        )
    case .gameAlreadyInProgressError: return accume
    case .gameStarted: return accume
    case .moveError: return accume
    }
}
