local DIARY_TEXTS = {
    "A word on the diary, before you open it.",
    "Every completed reading leaves a thread upon the page.",
    "Not the words spoken aloud, those belong to the moment alone.",
    "What stays is the record: which spread you chose,",
    "the date and hour, and every card drawn in its place.",
    "Name, position, orientation, and some whispers heard.",
    "When you finish a reading and step away, the spirits work hard to log it.",
    "They're fiddly wee things, please be patient with them.",
    "The air can get a bit thick while they carry, so forgive a brief stumble.",
    "But they do their best, bless them.",
    "Your diary waits behind a locked cover, bearing your name.",
    "The A button is the key. The pages will open.",
    "Browse by year, then month, then the day and time of each visit.",
    "The right-hand page holds a preview; crank when the ink runs long.",
    "To wander deeper into its months use your directions.",
    "When decided on an entry, open it fully.",
    "Inside, walk the spread and each card in turn.",
    "You can draw a card closer, or set it gently down again.",
    "Each card shows its place, its orientation, and the themes brought forth,",
    "enough to jog a memory without speaking for the cards.",
    "At the year list, ALTER lets you fiddle with the book:",
    "your chosen name upon the cover, space allowing.", 
    "And whether entries run oldest-first or newest-first.",
    "Remember to CLOSE when you are done. The lock will fall shut.",
    "You are welcome to return at any time, darling.",
    "A record kept is a lesson saved. Go well."
}

class('HowToDiaryScene').extends(BaseHowToScene)

function HowToDiaryScene:init()
    HowToDiaryScene.super.init(self, DIARY_TEXTS)
end
