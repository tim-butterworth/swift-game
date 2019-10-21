import Foundation

class EventSource {

    private weak var eventListener: EventListener?
    private var events: [Event] = []
    
    func addEvent(_ event: Event) {
        events.append(event)
        
        eventListener?.processEvent(event)
    }

    func getEvents(afterIndex: Int) -> ([Event], Int) {
        var eventsToReturn: [Event] = []
        var index = afterIndex
        while(index < events.count) {
            eventsToReturn.append(events[index])

            index = index + 1
        }
        
        return (eventsToReturn, eventsToReturn.count)
    }
    
    func registerEventListener(_ eventListener: EventListener) {
        self.eventListener = eventListener
        
        events.forEach {
            eventListener.processEvent($0)
        }
    }
}
