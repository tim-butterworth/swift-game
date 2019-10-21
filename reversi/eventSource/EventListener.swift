import Foundation

protocol EventListener: class {
    func processEvent(_ event: Event)
}

indirect enum StackNode<T> {
    case empty
    case data(data: T, next: StackNode<T>)
    
    func getNext() -> StackNode<T> {
        switch self {
        case .empty:
            return .empty
        case let .data(_, next):
            return next
        }
    }
}
