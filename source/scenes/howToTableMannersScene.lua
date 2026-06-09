local TABLE_MANNERS_TEXTS = {
    "First time? Don't fret. I'll hold the veil open for you.",
    "Before we begin, a little ritual etiquette.",
    "Find a quiet moment and set your intention.",
    "The cards respond best when asked with honesty, not panic.",
    "First, choose your layout and your tools.",
    "The Spreads can help you shape of the query; the Deck can provide the voice.",
    "When the choices feel right, press SEEK to begin the hunt.",
    "The spreads are merely standard paths through the woods,",
    "guides to help us interpret the shade.",
    "Feel free to wander off them and adapt as you see fit.",
    "If you wish to study the map closer, there is more information within.",
    "Touch the deck gently. You are asking, not demanding.",
    "Breathe in. Breathe out. Let the noise settle.",
    "One clear question is stronger than ten tangled ones.",
    "With cards in hand, shuffle until the rhythm feels true. Then step forward.",
    "Before a word is spoken, look to the Cloth. Cycle through the layout and look closer.",
    "See how the cards sit together in the quiet.",
    "When you are ready to hear what they have to say, advance.",
    "If a card unsettles you, sit with it before drawing again.",
    "Keep your readings kind. Even hard truths deserve care.",
    "And when you are done, thank the deck. Manners matter on both sides.",
    "At the journey's end, you will be prompted to choose: ",
    "Look back at the Cloth one last time, or step away.",
    "Whichever path you take to leave, the thread is caught.", 
    "The spirits commit the reading to your diary before closing the door.",
    "When the spirits go quiet, you may seek another reading.",
    "But remember, darling...",
    "The cards don't lie. Even when you do."
}

class('HowToTableMannersScene').extends(BaseHowToScene)

function HowToTableMannersScene:init()
    HowToTableMannersScene.super.init(self, TABLE_MANNERS_TEXTS)
end


