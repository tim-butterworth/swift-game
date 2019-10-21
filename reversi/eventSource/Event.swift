enum MoveErrorType {
    case moveAlreadyUsed
    case wrongPlayer
    case invalidPosition
}

enum Event: Equatable {
    case gameStarted
    case gameAlreadyInProgressError
    case madeMove(move: GameMove)
    case changePlayer(side: PlayerSide)
    case flip(coordinates: GameCoordinates)
    case moveError(_ errorType: MoveErrorType, move: GameMove)
}
