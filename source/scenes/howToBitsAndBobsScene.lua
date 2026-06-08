local BITS_AND_BOBS_TEXTS = {
    "A few practical bits before fate gets dramatic.",
    "If not prompted to press a button, don't fret.",
    "Trust the grid. It's your guide.",
    "Same overall rules for the lost...",
    "Use the d-pad to cycle through choices.",
    "Press A to confirm and advance through out.",
    "Press B to back out when you need to.",
    "In readings, crank to shuffle and wake the deck.",
    "When looking at the cloth, Left and Right cycle through the cards,",
    "Up and Down zoom in and out.",
    "Similarly for the Diary:",
    "the d-pad works for the left side of the page,",
    "the Crank for the right side.",
    "Take your time. Rushing blurs the mind.",
    "And if the answer feels strange, ask again tomorrow."
}

class('HowToBitsAndBobsScene').extends(BaseHowToScene)

function HowToBitsAndBobsScene:init()
    HowToBitsAndBobsScene.super.init(self, BITS_AND_BOBS_TEXTS)
end
