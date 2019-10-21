import Foundation

func initialMoveProjection() -> MakeMoveProjection {
    var initialBoard: [[Optional<PlayerSide>]] = []
    
    let lowerBound = GameCoordinate.four.rawValue
    let upperBound = GameCoordinate.m_four.rawValue
    (lowerBound...upperBound).forEach { x in
        var column: [Optional<PlayerSide>] = []
        (lowerBound...upperBound).forEach { y in
            column.append(.none)
        }
        initialBoard.append(column)
    }

    return MakeMoveProjection(
        moves: [],
        side: .black,
        board: initialBoard
    )
}
