local DIARY_TEXTS = {
    "Unlock your diary to begin your journey.",
    "The diary is your record of your readings.",
    "It is a record of your journey, of your growth, of your lessons."
}

class('HowToDiaryScene').extends(BaseHowToScene)

function HowToDiaryScene:init()
    HowToDiaryScene.super.init(self, DIARY_TEXTS)
end
