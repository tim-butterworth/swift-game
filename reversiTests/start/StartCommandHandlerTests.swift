import XCTest

@testable import reversi

class StartCommandHandlerTests: XCTestCase {
    
    var subject: CommandHandler<StartGameProjection>!
    var eventSource: EventSource!
    
    override func setUp() {
        eventSource = EventSource()
        subject = CommandHandler(
            initialState: StartGameProjection(gameState: .notStarted),
            eventSource: eventSource,
            updateProjection: startGameProjectionUpdater,
            applyCommand: startGameApplyCommands
        )
    }
    
    func testCanStartAGame() {
        subject.handleCommand(.newGame)
        
        let events = eventSource.getEvents(afterIndex: 0)
        
        XCTAssertEqual(events.0.count, 1)
    }

    func testDoesNotEmitEventsForOtherCommands() {
        subject.handleCommand(
            .makeMove(move: GameMove(coordinates: GameCoordinates(x: .four, y: .four), player: .black))
        )
        
        let events = eventSource.getEvents(afterIndex: 0)
        
        XCTAssertEqual(events.0.count, 0)
    }
    
    func testIfAGameIsAlreadyStaredEmitsAnErrorEvent() {
        eventSource.addEvent(.gameStarted)
        
        subject.handleCommand(.newGame)
        
        let events = eventSource.getEvents(afterIndex: 0)
        
        XCTAssertEqual(events.0.count, 2)
        XCTAssertEqual(events.0[1], .gameAlreadyInProgressError)
    }
}
