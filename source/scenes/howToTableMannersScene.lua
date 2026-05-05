local TABLE_MANNERS_TEXTS = {
    "Before we begin, a little ritual etiquette.",
    "Find a quiet moment and set your intention.",
    "The cards respond best when asked with honesty, not panic.",
    "Touch the deck gently. You are asking, not demanding.",
    "Breathe in. Breathe out. Let the noise settle.",
    "One clear question is stronger than ten tangled ones.",
    "If a card unsettles you, sit with it before drawing again.",
    "Keep your readings kind. Even hard truths deserve care.",
    "And when you are done, thank the deck. Manners matter on both sides."
}

class('HowToTableMannersScene').extends(BaseHowToScene)

function HowToTableMannersScene:init()
    HowToTableMannersScene.super.init(self, TABLE_MANNERS_TEXTS)
end
