import UIKit

class GameButton: UIButton {
    
    let coordinates: GameCoordinates
    
    init(coordinates: GameCoordinates, frame: CGRect) {
        self.coordinates = coordinates
        
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
