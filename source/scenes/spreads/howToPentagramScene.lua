local PENTAGRAM_TEXTS = {
    "Five cards. Five points. A little ritual geometry to keep the night organized.",
    "This spread asks for more patience. Each card has a place in the pattern.",
    "Shuffle until the deck feels properly unsettled.",
    "Turn the crank and let the circle gather its weight.",
    "Press A when you are ready to reveal the pentagram.",
    "The cards will appear one after another so you can feel the shape of the reading build.",
    "Each position speaks to a different force pressing on your question.",
    "Do not treat this one like a quick fortune. It has more corners to hide in.",
    "When the cards are down, I will name what each point is trying to tell you.",
    "If the spread feels dramatic, good. It was meant to be."
}

class('HowToPentagramScene').extends(BaseHowToScene)

function HowToPentagramScene:init()
    HowToPentagramScene.super.init(self, PENTAGRAM_TEXTS)
end
