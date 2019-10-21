import Foundation

enum PlayerSide {
    case white
    case black
    
    func opposite() -> PlayerSide {
        switch self {
        case .white: return .black
        case .black: return .white
        }
    }    
}

enum GameCoordinate: Int {
    case four = 0
    case three = 1
    case two = 2
    case one = 3
    case m_one = 4
    case m_two = 5
    case m_three = 6
    case m_four = 7
}

struct GameCoordinates: Equatable {
    let x: GameCoordinate
    let y: GameCoordinate
}

enum Command {
    case makeMove(move: GameMove)
    case newGame
}
