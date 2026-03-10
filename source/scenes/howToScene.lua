local ONE_CARD_TEXTS = {
    "Ah yes, curious one... I felt your energy long before you stepped in.",
    "First time? Don't fret. I'll hold the veil open for you.",
    "One card.\nOne glimpse beyond what most dare to seek.",
    "Shuffle the deck. Let fate crack its knuckles.",
    "Use the crank to stir your fate. The stars lean in when no one's looking.",
    "When your fingers grow restless, press A. I'll do the rest.",
    "Haste has its own magic, if you trust it.",
    "This is a single-card reading. Simple, but never shallow.",
    "Full deck or Major Arcana only? Depends how much truth you can handle.",
    "Once the card reveals itself...",
    "I listen. The whispers don't speak to just anyone.",
    "I won't stop you squinting at fate. Press A only if you're ready.",
    "Your fortune will rise like mist, or smoke, or something you forgot to name.",
    "When the spirits go quiet, you may seek another reading.",
    "I won't judge. Curiosity is practically holy.",
    "But remember, darling...\nThe cards don't lie.            Even when you do."
}

class('HowToScene').extends(BaseHowToScene)

function HowToScene:init()
    HowToScene.super.init(self, ONE_CARD_TEXTS)
end



