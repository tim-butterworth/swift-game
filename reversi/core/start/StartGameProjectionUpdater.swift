import Foundation

func startGameProjectionUpdater(_ state: StartGameProjection, _ events: [Event]) -> StartGameProjection {
    return events.reduce(state) { (accume: StartGameProjection, element: Event) -> StartGameProjection in
        switch element {
        case .gameStarted:
            return StartGameProjection(gameState: .inProgress)
        case .gameAlreadyInProgressError: return accume
        case .madeMove: return accume
        case .changePlayer: return accume
        case .flip: return accume
        case .moveError: return accume
        }
    }
}
