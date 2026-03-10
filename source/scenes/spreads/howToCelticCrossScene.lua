local CELTIC_CROSS_TEXTS = {
    "The Celtic Cross is not shy. Ten cards, ten angles, nowhere to hide.",
    "Choose this spread when your question has roots, branches, and a few inconvenient ghosts.",
    "Shuffle thoroughly. A half-hearted cross gives half-hearted truth.",
    "Use the crank to wake the deck before you press A.",
    "When you reveal, the cards will build a full spread instead of a single answer.",
    "Some positions describe the pressure around you. Others expose what is moving underneath.",
    "The later cards widen the lens. They ask how you stand inside the story.",
    "Do not panic if the table looks crowded. I know where to look.",
    "After the reveal, I will read the spread position by position.",
    "It is a long conversation, but the cross usually earns the trouble."
}

class('HowToCelticCrossScene').extends(BaseHowToScene)

function HowToCelticCrossScene:init()
    HowToCelticCrossScene.super.init(self, CELTIC_CROSS_TEXTS)
end
