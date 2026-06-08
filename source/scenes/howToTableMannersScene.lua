local TABLE_MANNERS_TEXTS = {
    "Before we begin, a little ritual etiquette.",
    "Find a quiet moment and set your intention.",
    "The cards respond best when asked with honesty, not panic.",
    "First, choose your layout and your tools.",
    "The Spreads will show you the shape of the query; the Deck will provide the voice.",
    "When the choices feel right, press SEEK to begin the hunt.",
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
    "A record kept is a lesson saved. Go well."
}

class('HowToTableMannersScene').extends(BaseHowToScene)

function HowToTableMannersScene:init()
    HowToTableMannersScene.super.init(self, TABLE_MANNERS_TEXTS)
end
