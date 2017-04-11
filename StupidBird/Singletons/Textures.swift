//
//  Textires.swift
//  StupidBird
//
//  Created by SangNP on 4/3/17.
//  Copyright © 2017 SangNP. All rights reserved.
//

import SpriteKit

class Textures {
    
    static let sharedInstance = Textures()
    
    // MARK: - Private class constants
    private let atlasName = "Sprites"
    
    // MARK: - Private class variables
    private var sprites = SKTextureAtlas()
    
    // MARK: - Init
    init() {
        self.sprites = SKTextureAtlas(named: atlasName)
    }
    
    // MARK: - Public convenience functions
    func textureWith(name: String) -> SKTexture {
        return sprites.textureNamed(name)
    }
    
    func spriteWith(name: String) -> SKSpriteNode {
        let texture = sprites.textureNamed(name)
        return SKSpriteNode(texture: texture)
    }

}
