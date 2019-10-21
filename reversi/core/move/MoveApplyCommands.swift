import Foundation

struct MakeMoveProjection {
    let moves: [GameMove]
    let side: PlayerSide
    let board: [[PlayerSide?]]
}

func moveApplyCommand(
    _ state: MakeMoveProjection,
    _ command: Command
) -> [Event] {
    switch command {
    case let .makeMove(move):
        if (move.player != state.side) {
            return [.moveError(.wrongPlayer, move: move)]
        }

        if let _ = state.board[move.coordinates.x.rawValue][move.coordinates.y.rawValue] {
            return [.moveError(.moveAlreadyUsed, move: move)]
        }

        let events = getChangeEvents(state.board, move)

        if (events.isEmpty) {
            return [.moveError(.invalidPosition, move: move)]
        } else {
            var moveAndFlips: [Event] = [.madeMove(move: move)]
            
            let nextSide = getNextSide(move.player, state.board)
            
            if (nextSide != move.player) {
                moveAndFlips.append(.changePlayer(side: nextSide))
            }
            
            moveAndFlips.append(contentsOf: events)
            return moveAndFlips
        }
    case .newGame: return []
    }
}

private func getChangeEvents(_ board: [[PlayerSide?]], _ move: GameMove) -> [Event] {
    let events: [Event] = hasOppositeNeighbor(board, move).map { end -> [Event] in
        let direction = getDirection(start: move, end: end)
        
        return getElementsToFlip(move, direction, board).map { (c: GameCoordinates) in
            .flip(coordinates: c)
        }
    }.reduce([]) { (accume, entry) in
        var updateableAccume = accume
        updateableAccume.append(contentsOf: entry)
        
        return updateableAccume
    }
    
    return events
}

private func getNextSide(_ side: PlayerSide, _ board: [[PlayerSide?]]) -> PlayerSide {    
    return side.opposite()
}

private func getDirection(start: GameMove, end: GameMove) -> (x: Int, y: Int) {
    let startX = start.coordinates.x.rawValue
    let startY = start.coordinates.y.rawValue
    
    let endX = end.coordinates.x.rawValue
    let endY = end.coordinates.y.rawValue
    
    return (x: endX - startX, y: endY - startY)
}

private func hasOppositeNeighbor(_ board: [[PlayerSide?]], _ move: GameMove) -> [GameMove] {
    let side = move.player
    let coordinates = move.coordinates
    
    let neighbors = neighborFunctions.reduce([]) { (accume: [GameCoordinates], fun: (GameCoordinates) -> GameCoordinates?) in
        var updatedAccume = accume
        if let gameCoordinate = fun(coordinates) {
            updatedAccume.append(gameCoordinate)
        }
        return updatedAccume
    }
    
    return neighbors.filter { gameCoordinates in
        let x = gameCoordinates.x.rawValue
        let y = gameCoordinates.y.rawValue
        
        return board[x][y].map { $0 != side } ?? false
    }.map { gameCoordinates in
        return GameMove(coordinates: gameCoordinates, player: side.opposite())
    }
}

private func getElementsToFlip(_ move: GameMove, _ direction: (x: Int, y: Int), _ board: [[PlayerSide?]]) -> [GameCoordinates] {
    var currentPosition = (
        x: move.coordinates.x.rawValue + direction.x,
        y: move.coordinates.y.rawValue + direction.y
    )

    let toCoordinates = { (x: Int, y: Int) -> GameCoordinates? in
        let xCoordinate = GameCoordinate(rawValue: x)
        let yCoordinate = GameCoordinate(rawValue: y)

        switch (xCoordinate, yCoordinate) {
        case (.none, _): return .none
        case (_, .none): return .none
        case let (.some(x), .some(y)): return GameCoordinates(x: x, y: y)
        }
    }
    
    let side = move.player.opposite()
    var positionstToFlip: [GameCoordinates] = []
    var keepGoing = true
    while (keepGoing) {
        let currentCoordinates = toCoordinates(currentPosition.x, currentPosition.y)
        
        switch currentCoordinates {
        case .none:
            positionstToFlip = []
            keepGoing = false
        case let .some(coordinates):
            switch board[currentPosition.x][currentPosition.y] {
            case .none: positionstToFlip = []
            case let .some(boardSide):
                if (boardSide == side) {
                    positionstToFlip.append(coordinates)
                } else {
                    keepGoing = false
                }
            }
            currentPosition = (x: currentPosition.x + direction.x, y: currentPosition.y + direction.y)
        }
    }
    
    return positionstToFlip
}

private func maybeBuildGameCoordinate(x: GameCoordinate?, y: GameCoordinate?) -> GameCoordinates? {
    switch (x, y) {
    case (.none, _): return .none
    case (_, .none): return .none
    case let (.some(xValue), .some(yValue)): return GameCoordinates(x: xValue, y: yValue)
    }
}
private let neighborFunctions = [
    getTransform((x: -1, y: -1)),
    getTransform((x: 0, y: -1)),
    getTransform((x: 1, y: -1)),
    getTransform((x: 1, y: 0)),
    getTransform((x: 1, y: 1)),
    getTransform((x: 0, y: 1)),
    getTransform((x: -1, y: 1)),
    getTransform((x: -1, y: 0))
]

func getTransform(_ transform: (x: Int, y: Int)) -> ((GameCoordinates) -> GameCoordinates?) {
    return { (coordinats: GameCoordinates) -> GameCoordinates? in
        let x = GameCoordinate(rawValue: coordinats.x.rawValue + transform.x)
        let y = GameCoordinate(rawValue: coordinats.y.rawValue + transform.y)
        
        return maybeBuildGameCoordinate(x: x, y: y)
    }
}
