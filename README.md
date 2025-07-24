# Wee Tarot

A mystical single-card tarot reading game for the [Playdate](https://play.date) handheld console, featuring atmospheric scenes, crank-controlled shuffle mechanics, and witty fortune telling with original card interpretations.

**🎮💛 [Gaem page on itch.io](https://mama666.itch.io/wee-tarot)**

![Wee Tarot gameplay](https://img.itch.zone/aW1hZ2UvMjgyNjIwNi8xNjc4NDMyNy5naWY=/original/FJ2yBr.gif)

## 📖 About the Game

Wee Tarot transforms the ancient art of tarot reading into an interactive digital experience. Players use the Playdate's unique crank mechanism to shuffle a mystical deck, draw cards, and receive personalized fortune readings from Dinah, your enigmatic tarot reader guide.

### ✨ Key Features

- **Crank-Controlled Shuffling**: Use the Playdate's signature crank to physically shuffle the deck
- **78-Card Tarot Deck**: Complete deck with Major Arcana and all four suits (Cups, Wands, Swords, Pentacles)
- **Dynamic Card Readings**: Each card offers multiple fortune variations with upright/reversed meanings
- **Atmospheric Experience**: Lofi background music, ambient rain, and carefully crafted sound design
- **Multiple Reading Modes**: Choose between full deck or Major Arcana only readings
- **Inverted Cards**: Cards can appear upside-down for reversed meanings, adding depth to readings
- **Character-Driven Narration**: Dinah provides mystical, often humorous interpretations

## 🎯 Game Design Philosophy

Wee Tarot balances respect for tarot tradition with playful, accessible game design:

- **Authentic yet Approachable**: Traditional tarot structure with modern, witty interpretations
- **Physical Interaction**: The crank creates a tactile connection to the mystical act of shuffling
- **Atmospheric Immersion**: Visual and audio design evoke a cozy, mystical reading space
- **Replayability**: Multiple fortune variations ensure fresh readings each time

## 🛠️ Technical Implementation

### Architecture & Code Design

- **Scene Management System**: Custom scene manager with fade transitions and comprehensive memory management (inspired by SquidGod's scene management patterns)
- **Animation Framework**: Integration of [AnimatedSprite library](https://github.com/Whitebrim/AnimatedSprite) with custom modifications for frame control
- **Sound Synchronization**: Real-time crank sound feedback and layered atmospheric audio
- **Memory Optimization**: Critical for Playdate hardware constraints with defensive cleanup patterns
- **State Machine Design**: Clean state transitions for shuffle → reveal → fortune sequence

### Platform-Specific Features

- **Playdate SDK**: Built with Lua using official Playdate CoreLibs
- **1-bit Graphics**: All visuals designed for Playdate's unique black-and-white dithered display
- **Hardware Crank Integration**: Custom input handling for smooth shuffle mechanics
- **Button Controls**: A/B buttons for navigation and interaction
- **Audio System**: Optimized .pda audio files for Playdate's audio capabilities

### Key Technical Challenges Solved

1. **Memory Management**: Implemented comprehensive sprite/timer cleanup for hardware limitations
2. **Animation Timing**: Complex animation chains with precise timing coordination
3. **Crank Responsiveness**: Achieved smooth crank-to-animation synchronization with audio feedback
4. **Data Organization**: Structured 78-card dataset with multiple fortune variations per card
5. **Scene Transitions**: Smooth fade effects without memory leaks or visual artifacts

## 📁 Project Structure

```
source/
├── main.lua                 # Entry point, global sound system, font setup
├── scenes/                  # Scene management and game flow
│   ├── sceneManager.lua    # Custom scene transition system with fade effects
│   ├── gameScene.lua       # Main gameplay: shuffle, crank controls, card drawing
│   ├── postScene.lua       # Fortune reading display with text scrolling
│   ├── menuScene.lua       # Navigation and character animations
│   └── titleScene.lua      # Animated title sequence
├── libraries/              # External libraries and utilities
│   ├── AnimatedSprite.lua  # Third-party animation system (MIT License)
│   └── utils.lua           # Text effects and helper functions
├── data/                   # Card content and game data
│   ├── cardDescriptions.lua      # Master card data aggregation
│   ├── cardDescriptionsMajor.lua # Major Arcana descriptions
│   ├── cardDescriptionsCups.lua  # Cups suit data
│   ├── cardDescriptionsWands.lua # Wands suit data
│   ├── cardDescriptionsSwords.lua# Swords suit data
│   └── cardDescriptionsPentacles.lua # Pentacles suit data
├── scripts/                # Game logic and mechanics
│   ├── card.lua           # Card sprite behavior and inversion logic
│   ├── deck.lua           # Deck management and card drawing
│   └── decks/             # Individual suit definitions
├── images/                # Art assets organized by type
│   ├── bg/                # Background images
│   ├── shuffleAnimation/  # Frame-by-frame shuffle animations
│   ├── cups/              # Cups suit card images
│   ├── wands/             # Wands suit card images
│   ├── swords/            # Swords suit card images
│   ├── pentacles/         # Pentacles suit card images
│   └── majorArcana/       # Major Arcana card images
└── sound/                 # Audio assets (.wav source, .pda compiled)
    ├── bgMusic3quieter.wav     # Lofi background music
    ├── rain1quieter.wav        # Ambient rain sounds
    ├── crank5.wav              # Crank rotation sound
    └── cards_*.wav             # Various card interaction sounds
```

## 🐍 Development Tools

The card data and animations were created with custom Python tools, showcasing full-stack game development skills:

**[🔗 Wee Tarot Tools Repository](https://github.com/mama-cailleach/python-portfolio/tree/main/python-experiments/wee-tarot-tools)**

### Animation Tools (`shuffleAnimation/`)
- **Visual Prototyping**: Python scripts for testing shuffle effects and card animations
- **Asset Generation**: Automated spritesheet creation from individual card images
- **Animation Preview**: GIF generation for iteration and preview
- **Effect Creation**: Circular shuffling, hand shuffling, scaling, fan spreads, and explosive finales

### Data Tools (`generate_card_data/`)
- **Content Pipeline**: Automated conversion from CSV/Excel to Lua tables
- **Card Database**: Streamlined process for adding new card descriptions and correspondences
- **Format Conversion**: Bridge between design documents and game-ready code
- **Scalability**: Easily adaptable for other card sets or tarot variations

## 🎨 Creative Implementation

### Card Content Design
- **Original Interpretations**: 78 unique cards with multiple fortune variations each
- **Tone Balance**: Mystical authenticity with contemporary humor and relatability
- **Multiple Variations**: Each card offers several different fortune readings for replayability
- **Upright/Reversed**: Traditional tarot structure with distinct meanings for card orientation

### Visual Design
- **Playdate Aesthetic**: All graphics optimized for 1-bit display with careful dithering
- **Pixel Art Cards**: Custom tarot card designs by Sarah Seekins
- **Animation Sequences**: Hand-crafted shuffle animations and spritesheets with 60+ frames
- **UI/UX Flow**: Intuitive scene transitions maintaining mystical atmosphere
- **Typography**: Custom Tarotheque font family enhancing the mystical theme
- **Mixed Media Assets**: Combination of pixel art, photography adaptations, and custom art

### Audio Design
- **Layered Soundscape**: Background music, ambient rain, and interactive sound effects
- **Crank Feedback**: Real-time audio response to physical crank interaction
- **Atmospheric Immersion**: Carefully balanced audio levels for contemplative experience
- **Audio Integration**: In-game mixing, cutting, and tweaking of original compositions

## 🚀 Development Highlights

### Game Programming Skills Demonstrated
- **Hardware Integration**: Custom crank input handling with real-time feedback
- **Memory Optimization**: Essential for handheld console development
- **Animation Systems**: Complex state-based animations with event callbacks
- **Audio Programming**: Multi-layered sound design with dynamic mixing
- **Scene Architecture**: Scalable scene management with clean transitions

### Software Engineering Practices
- **Clean Architecture**: Modular scene system with separation of concerns
- **Defensive Programming**: Comprehensive error handling and resource cleanup
- **Performance Optimization**: Frame-rate considerations for 1-bit hardware
- **Cross-Platform Tools**: Python pipeline for content creation and asset generation
- **Version Control**: Structured Git workflow for game development

## 🎯 Portfolio Significance

Wee Tarot demonstrates:

1. **Full-Stack Game Development**: From Python tools to Lua implementation to final Playdate deployment
2. **Hardware-Specific Programming**: Working within unique console constraints and capabilities
3. **User Experience Design**: Creating intuitive interactions with unconventional input methods
4. **Content Creation Pipeline**: Efficient tools for managing large datasets (78 cards × multiple variations)
5. **Audio-Visual Coordination**: Synchronized sound, animation, and user input
6. **Cross-Disciplinary Skills**: Programming, game design, content writing, audio design, and user experience

## 🔧 Build & Development

### Prerequisites
- [Playdate SDK](https://play.date/dev/) (includes Lua runtime and development tools)
- [PlaydateSimulator](https://help.play.date/dev/simulator/) for testing

### Building the Game
```bash
# Navigate to source directory
cd "source/"

# Build using Playdate compiler
pdc . "Wee Tarot.pdx"

# Run in simulator
playdate-simulator "Wee Tarot.pdx"
```

### Development Workflow
1. **Code in Lua**: Using Playdate SDK CoreLibs and custom libraries
2. **Test in Simulator**: Rapid iteration with PlaydateSimulator
3. **Deploy to Hardware**: Final testing on actual Playdate console
4. **Asset Pipeline**: Python tools for content creation and sprite generation

## 🎮 Controls

- **🎲 Crank**: Shuffle the deck (rotate to cycle through cards)
- **🅰️ A Button**: Confirm selection, advance text, interact
- **🅱️ B Button**: Back, navigate menus
- **🎛️ D-Pad**: Menu navigation

## 🌟 Credits

- **Programming & Game Design**: mama
- **Card Interpretations & Writing**: mama
- **Original Music, Ambience & Sound Effects**: [Filipe Miu](https://filipemiu.music/)
- **Audio Integration & Mixing**: mama (cutting, tweaking, and in-game integration)
- **Pixel Tarot Cards, Card Reveal Animation & Sky Background**: [Sarah Seekins](https://chee-seekins.itch.io)
- **Additional Art Assets & Adaptations**: mama (including photography, animations, and spritesheets)
- **Font**: [Tarotheque](https://www.dafont.com/gschaftlhuber.d11133) by Gschaftlhuber
- **Animation Library**: [AnimatedSprite](https://github.com/Whitebrim/AnimatedSprite) by @Whitebrim (MIT License) with custom modifications
- **Scene Management Inspiration**: SquidGod's scene management patterns

## 📄 License

See [LICENSE](LICENSE) for details.

---

*Wee Tarot represents a unique intersection of traditional mysticism and modern interactive design, showcasing technical proficiency in constrained hardware environments while delivering an engaging, atmospheric gaming experience.*
