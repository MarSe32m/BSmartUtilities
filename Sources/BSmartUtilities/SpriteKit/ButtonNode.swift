//
//  ButtonNode.swift
//
//
//  Created by Sebastian on 11/12/2018.
//  Copyright © 2018 Sebastian Toivonen. All rights reserved.
//

import Foundation
import SpriteKit

protocol ButtonNodeResponderType: class {
    func buttonTriggered(button: ButtonNode)
    func buttonTriggerBegan(button: ButtonNode)
    func buttonTriggerOutside(button: ButtonNode)
}

/// The complete set of button identifiers supported in the app.
enum ButtonIdentifier: String, CaseIterable {
    case hannele = "hannele_button"
    case dage = "dage_button"
    case danni = "danni_button"
    case kaitsu = "kaitsu_button"
    case alex = "alex_button"
    case natta = "natta_button"
    case adde = "adde_button"
    case dimi = "dimi_button"
    case jonsku = "jonsku_button"
    case sebbu = "sebbu_button"
    case nameSceneProceed = "name_scene_proceed_button"
    
    case play = "play_button"
    case back = "back_button"
    
    case charHippo = "character_hippo_button"
    case charChick = "character_chick_button"
    case charPig = "character_pig_button"
    case charMonkey = "character_monkey_button"
    case charOwl = "character_owl_button"
    case charWolf = "character_wolf_button"
    case charHorse = "character_horse_button"
    case charRihno = "character_rihno_button"
    case charChicken = "character_chicken_button"
    case charBear = "character_bear_button"
    case charGiraffe = "character_giraffe_button"
    
    
    /// The name of the texture to use for a button when the button is selected.
    var selectedTextureName: String? {
        switch self {
        case .hannele, .dage, .danni, .kaitsu, .alex, .natta, .adde, .dimi, .jonsku, .sebbu:
            return "button_texture_name_pressed"
        case .nameSceneProceed:
            return "button_texture_proceed_pressed"
        default:
            return nil
        }
    }
}

/// A custom sprite node that represents a press able and selectable button in a scene.
class ButtonNode: SKSpriteNode {
    // MARK: Properties
    
    /// The identifier for this button, deduced from its name in the scene.
    var buttonIdentifier: ButtonIdentifier
    
    /**
     The scene that contains a `ButtonNode` must be a `ButtonNodeResponderType`
     so that touch events can be forwarded along through `buttonPressed()`.
     */
    var responder: ButtonNodeResponderType {
        guard let responder = scene as? ButtonNodeResponderType else {
            fatalError("ButtonNode may only be used within a `ButtonNodeResponderType` scene.")
        }
        return responder
    }
    
    /// Indicates whether the button is currently highlighted (pressed).
    var isHighlighted = false {
        // Animate to a pressed / unpressed state when the highlight state changes.
        didSet {
            // Guard against repeating the same action.
            guard oldValue != isHighlighted else { return }
            
            // Remove any existing animations that may be in progress.
            removeAllActions()
            
            // Create a scale action to make the button look like it is slightly depressed.
            let newScale: CGFloat = isHighlighted ? 0.92 : 1.0
            let scaleAction = SKAction.scale(to: newScale, duration: 0.11)
            var scaleOther = SKAction()
            if newScale == 1.0 {
                scaleOther = SKAction.scale(to: 1.1, duration: 0.11)
                scaleOther.timingMode = .easeIn
            }
            scaleAction.timingMode = .easeOut
            let seq = SKAction.sequence([scaleOther, scaleAction])
            // Create a color blend action to darken the button slightly when it is depressed.
            let newColorBlendFactor: CGFloat = isHighlighted ? 0.5 : 0.0
            let colorBlendAction = SKAction.colorize(withColorBlendFactor: newColorBlendFactor, duration: seq.duration)
            var setTexture = SKAction()
            if let selectedTexture = selectedTexture, let defaultTexture = defaultTexture {
                setTexture = SKAction.setTexture(isHighlighted ? selectedTexture : defaultTexture)
            }
            // Run the two actions at the same time.
            run(SKAction.group([seq, colorBlendAction, setTexture]))
            
        }
    }
    
    /**
     Indicates whether the button is currently selected (on or off).
     Most buttons do not support or require selection. In DemoBots,
     selection is used by the screen recorder buttons to indicate whether
     screen recording is turned on or off.
     */
    var isSelected = false {
        didSet {
            // Change the texture based on the current selection state.
            texture = isSelected ? selectedTexture : defaultTexture
        }
    }
    
    /// The texture to use when the button is not selected.
    var defaultTexture: SKTexture?
    
    /// The texture to use when the button is selected.
    var selectedTexture: SKTexture?
    
    // MARK: Initializers
    
    /// Overridden to support `copy(with zone:)`.
    override init(texture: SKTexture?, color: SKColor, size: CGSize) {
        buttonIdentifier = .nameSceneProceed
        super.init(texture: texture, color: color, size: size)
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.buttonIdentifier = .nameSceneProceed
        super.init(coder: aDecoder)
        
        // Ensure that the node has a supported button identifier as its name.
        guard let nodeName = name, let buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
            fatalError("Unsupported button name found.")
        }
        self.buttonIdentifier = buttonIdentifier
        
        // Remember the button's default texture (taken from its texture in the scene).
        defaultTexture = texture
        
        if let textureName = buttonIdentifier.selectedTextureName {
            selectedTexture = SKTexture(imageNamed: textureName)
        }
        else {
            selectedTexture = texture
        }
        
        
        // Enable user interaction on the button node to detect tap and click events.
        isUserInteractionEnabled = true
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let newButton = super.copy(with: zone) as! ButtonNode
        
        // Copy the `ButtonNode` specific properties.
        newButton.buttonIdentifier = buttonIdentifier
        newButton.defaultTexture = defaultTexture?.copy() as? SKTexture
        newButton.selectedTexture = selectedTexture?.copy() as? SKTexture
        
        return newButton
    }
    
    func buttonTriggered() {
        if isUserInteractionEnabled {
            responder.buttonTriggered(button: self)
        }
    }
    
    func buttonTriggerBegan() {
        if isUserInteractionEnabled {
            responder.buttonTriggerBegan(button: self)
        }
    }
    
    func buttonTriggerOutside() {
        if isUserInteractionEnabled {
            responder.buttonTriggerOutside(button: self)
        }
    }
    
    // MARK: Responder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if containsTouches(touches: touches) {
            buttonTriggerBegan()
        }
        isHighlighted = true
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        isHighlighted = containsTouches(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        isHighlighted = false
        
        // Touch up inside behavior.
        if containsTouches(touches: touches) {
            buttonTriggered()
        } else {
            buttonTriggerOutside()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        super.touchesCancelled(touches!, with: event)
        
        isHighlighted = false
    }
    
    /// Determine if any of the touches are within the `ButtonNode`.
    private func containsTouches(touches: Set<UITouch>) -> Bool {
        guard let scene = scene else { fatalError("Button must be used within a scene.") }
        
        return touches.contains { touch in
            let touchPoint = touch.location(in: scene)
            let touchedNode = scene.atPoint(touchPoint)
            return touchedNode === self || touchedNode.inParentHierarchy(self)
        }
    }
}
