local PENTAGRAM_TEXTS = {
    "Ah, looking at the five-pointed star, are we?", 
    "This is the Pentagram. Five cards to look at the whole of you.",
    "A young lad once told me this reminded him of some old television cartoon.",
    "A load of nonsense, if you ask me.", 
    "Out here, the elements aren't a team of ring powered superheroes.",
    "No, in these parts the elements are fierce. They are:", 
    "the driving rain, the burning peat, the howling gale, the heavy bog." ,
    "All swirling around the stubborn spark of the soul.",
    "We go anti-clockwise, starting from the top.",
    "First is the Soul. The internal spark, the quiet center of the storm.", 
    "The things that haunt or drive you when the lights go out.",
    "Then comes Air. Your thoughts, the cold wind, sharp clarity.", 
    "Or the anxieties carried on the breeze.",
    "Next is Earth. Practicalities, survival, the physical body, coin...", 
    "And the stubborn realities that anchor you to the mud.",
    "Then Fire! Your drive, passion, anger!", 
    "The heat that either warms the hearth or burns the house down.",
    "And finally, Water. Feelings, intuition, tears...", 
    "the deep emotional currents you simply cannot control.",
    "Now, a wee secret for the clever ones: if you use the Alternate Deck here,", 
    "the cards will align perfectly with their true houses.",
    "The Soul takes a Major Arcana, Air claims the Swords,", 
    "Earth takes the Wands, Fire takes the Pentacles, Water takes the Cups.", 
    "It binds the whole thing tight.",
    "Let the elements churn in your hands.",
    "If the spread feels dramatic, good. It was meant to be."
}

class('HowToPentagramScene').extends(BaseHowToScene)

function HowToPentagramScene:init()
    HowToPentagramScene.super.init(self, PENTAGRAM_TEXTS)
end
