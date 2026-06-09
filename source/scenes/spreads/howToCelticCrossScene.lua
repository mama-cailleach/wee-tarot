local CELTIC_CROSS_TEXTS = {
    "Ah... the Celtic Cross. The grandest map of them all.", 
    "Ten cards to lay bare the whole landscape.",
    "You've likely seen them carved in stone, standing quiet in the old kirkyards,",
    "moss covered and weather beaten, holding the weight of centuries. ",
    "They don't flinch at the rain, and this spread won't flinch at your truths either.",
    "We begin at the heart of the stone, where two cards cross.", 
    "First is your Present Situation.",
    "The immediate reality and exactly where your feet are planted right now.",
    "Crossed over it is the Problem.", 
    "The challenge blocking your path, the immediate knot to be untied.",
    "Then we look to the four directions around the cross.", 
    "Beneath you is the Past:",
    "what has already happened and the history carrying you into this moment.",
    "Above you is the Conscious:", 
    "your goals and visible assumptions, what your mind is stubborn about.",
    "Behind you is the Unconscious:",
    "hidden motives, repressed truths, quiet forces driving you from the dark.",
    "Ahead is the Future: the short term momentum.",
    "What is currently drifting toward you on the immediate horizon.",
    "Then, we raise the staff of the cross, four cards stacked high.", 
    "First is Your Influence:", 
    "your self-perception, your agency, and the attitude you project into the world.",
    "Above that is the External Influence:", 
    "the surrounding environment, other people's actions,", 
    "the outside forces you cannot control.",
    "Next your Hopes and Fears: hidden desires, anxieties...", 
    "The strange way we often long for the very things we dread.",
    "And at the very top sits the Outcome.", 
    "The inevitable destination of your current momentum, the summary of the tale.",
    "It's a lot of stone to dig through, so take your time.", 
    "Let your mind become as still as an old graveyard.",
    "It is a long conversation, but the cross usually earns the trouble."
}

class('HowToCelticCrossScene').extends(BaseHowToScene)

function HowToCelticCrossScene:init()
    HowToCelticCrossScene.super.init(self, CELTIC_CROSS_TEXTS)
end
