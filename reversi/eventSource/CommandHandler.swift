import Foundation

typealias UpdateProjection<S> = (S, [Event]) -> S
typealias ApplyCommand<S> = (S, Command) -> [Event]

class CommandHandler<ProjectionState> {

    private var state: ProjectionState
    private var lastEventIndex: Int
    
    private let eventSource: EventSource

    private let updateProjection: UpdateProjection<ProjectionState>
    private let applyCommand: ApplyCommand<ProjectionState>
    
    init(
        initialState: ProjectionState,
        eventSource: EventSource,
        updateProjection: @escaping UpdateProjection<ProjectionState>,
        applyCommand: @escaping ApplyCommand<ProjectionState>
    ) {
        state = initialState
        self.eventSource = eventSource
        self.updateProjection = updateProjection
        self.applyCommand = applyCommand
        
        lastEventIndex = 0
    }

    func handleCommand(_ command: Command) {
        let (events, eventCount) = eventSource.getEvents(afterIndex: lastEventIndex)
        lastEventIndex = lastEventIndex + eventCount
        
        state = updateProjection(state, events)

        applyCommand(state, command).forEach {
            eventSource.addEvent($0)
        }
    }
}
