import UIKit

class GameController: UIViewController {
    
    private let commandDispatcher: CommandDispatcher
    private var state: Game
    
    init(
        commandDispatcher: @escaping CommandDispatcher,
        eventSource: EventSource
    ) {
        self.commandDispatcher = commandDispatcher
        state = initialState()
        
        super.init(nibName: nil, bundle: nil)
        
        eventSource.registerEventListener(self)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blue
        
        renderState(state)
    }
    
    private func renderState(_ gameState: Game) {
        if (gameState.moves.isEmpty) {
            showStartButton()
        } else {
            DispatchQueue.main.async {
                self.showBoard(gameState)
            }
        }
    }
    
    private func showStartButton() {
        let startButton = UIButton(frame: CGRect(
            x: 100,
            y: 100,
            width: 200,
            height: 20
        ))
        startButton.setTitle("START NEW GAME", for: .normal)
        startButton.addTarget(
            self,
            action: #selector(startNewGame),
            for: .touchUpInside
        )
        startButton.backgroundColor = UIColor.gray
        
        view.addSubview(startButton)
    }
    
    private func showBoard(_ gameState: Game) {
        view.subviews.forEach {
            $0.removeFromSuperview()
        }
        var buttons: [[UIButton]] = []
        
        
        let margin = 2
        let width = 40
        let height = 40
        
        let fullWidth = view.frame.width
        let fullHeight = view.frame.height

        let sideColor = UIView(
            frame: CGRect(
                x: 30,
                y: 170,
                width: 80,
                height: 15
            )
        )
        sideColor.backgroundColor = colorFromSide(gameState.currentTurn)
        view.addSubview(sideColor)

        let getMoveSideCount = { (moves: [GameMove], side: PlayerSide) in
            return moves.reduce(0) { (accume, value) in
                if (value.player == side) {
                    return accume + 1
                } else {
                    return accume
                }
            }
        }
        let whiteCountLabel = UILabel(
            frame: CGRect(
                x: 30,
                y: 200,
                width: 80,
                height: 15
            )
        )
        let whiteCount = getMoveSideCount(state.moves, .white)
        whiteCountLabel.text = "white: \(whiteCount)"
        view.addSubview(whiteCountLabel)

        let blackCountLabel = UILabel(
            frame: CGRect(
                x: 30,
                y: 230,
                width: 80,
                height: 15
            )
        )
        let blackCount = getMoveSideCount(state.moves, .black)
        blackCountLabel.text = "black: \(blackCount)"
        view.addSubview(blackCountLabel)

        let boardSideLength = CGFloat((width * 8) + (margin * 7))
        
        let xOffset = (fullWidth - boardSideLength) / 2
        let yOffset = (fullHeight - boardSideLength) / 2
        
        (0...7).forEach { (x: Int) in
            var row: [UIButton] = []
            (0...7).forEach { (y: Int) in
                let button = GameButton(
                    coordinates: GameCoordinates(
                        x: GameCoordinate(rawValue: x)!,
                        y: GameCoordinate(rawValue: y)!
                    ),
                    frame: CGRect(
                        x: CGFloat((width + margin) * x) + xOffset,
                        y: CGFloat((height + margin) * y) + yOffset,
                        width: CGFloat(width),
                        height: CGFloat(height)
                    )
                )
                
                button.backgroundColor = UIColor.green
                button.addTarget(self, action: #selector(gameButtonTapped), for: .touchUpInside)
                
                row.append(button)
            }
            buttons.append(row)
        }
        
        gameState.moves.forEach { move in
            let coordinates = move.coordinates
            let side = move.player
            
            let selectedButton = buttons[coordinates.x.rawValue][coordinates.y.rawValue]

            let circleView = UIView(frame: CGRect(x: 4, y: 4, width: width - 8, height: height - 8))
            circleView.layer.cornerRadius = CGFloat((width - 8) / 2)
            circleView.isUserInteractionEnabled = false
            
            switch side {
            case .black: circleView.backgroundColor = UIColor.black
            case .white: circleView.backgroundColor = UIColor.white
            }
            
            selectedButton.backgroundColor = UIColor.green
            selectedButton.addSubview(circleView)
            selectedButton.layer.cornerRadius = 4
        }
        
        if let errorMove = gameState.errorMove {
            let errorCoordinates = errorMove.coordinates
            
            let errorButton = buttons[errorCoordinates.x.rawValue][errorCoordinates.y.rawValue]
            errorButton.backgroundColor = UIColor.red
        }

        buttons.forEach { row in
            row.forEach { button in
                view.addSubview(button)
            }
        }
    }
    
    private func colorFromSide(_ side: PlayerSide) -> UIColor {
        switch side {
        case .black: return UIColor.black
        case .white: return UIColor.white
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func startNewGame(_ button: UIButton) {
        print("\(button.titleLabel?.text ?? "")")
        
        commandDispatcher(Command.newGame)
    }
    
    @objc func gameButtonTapped(_ button: GameButton) {
        let coordinates = button.coordinates
        
        self.commandDispatcher(
            .makeMove(
                move: GameMove(
                    coordinates: GameCoordinates(
                        x: coordinates.x,
                        y: coordinates.y
                    ),
                    player: self.state.currentTurn
                )
            )
        )
    }
}

extension GameController: EventListener {
    func processEvent(_ event: Event) {
        let updatedState = updateState(state, event)

        if (updatedState != state) {
            state = updatedState
            
            self.renderState(state)
        }
    }
}
