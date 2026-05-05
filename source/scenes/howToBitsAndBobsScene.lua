local BITS_AND_BOBS_TEXTS = {
    "A few practical bits before fate gets dramatic.",
    "Use Up and Down to move menu choices.",
    "Press A to confirm selections and advance text.",
    "Press B to back out of menus when you need to.",
    "In readings, crank to shuffle and wake the deck.",
    "Take your time. Rushing a reading blurs the message.",
    "Try different spreads when one card feels too small.",
    "And if the answer feels strange, ask again tomorrow."
}

class('HowToBitsAndBobsScene').extends(BaseHowToScene)

function HowToBitsAndBobsScene:init()
    HowToBitsAndBobsScene.super.init(self, BITS_AND_BOBS_TEXTS)
end
