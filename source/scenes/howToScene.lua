local ONE_CARD_TEXTS = {
    "Ah yes, curious one... I felt your energy long before you stepped in.",
    "The 1-Bit Fortune. A single card, pinned down, ", 
    "like a silver Luckenbooth brooch to lock your fate for a moment.",
    "One card.",
    "One glimpse beyond what most dare to seek.",
    "This is a single-card reading. Simple, but never shallow.",
    "Shuffle the deck. Let fate crack its knuckles.",
    "While you shuffle, the cards are listening.", 
    "One might just pop right out on its own before you've decided.", 
    "If it falls, it was meant for you. Haste has its own magic, if you trust it.",
    "Once the card reveals itself...",
    "I listen. The whispers don't speak to just anyone.",
    "I won't stop you squinting at fate. Advance only if you're ready.",
    "Your fortune will rise like mist, or smoke, or something you forgot to name.",
    "Now off you go, and mind you don't argue with the card.",
    "It's older than you, and twice as crabbit."
}

class('HowToScene').extends(BaseHowToScene)

function HowToScene:init()
    HowToScene.super.init(self, ONE_CARD_TEXTS)
end



