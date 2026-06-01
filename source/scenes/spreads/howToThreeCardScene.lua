local THREE_CARD_TEXTS = {
    "Three cards this time. Root, Trunk, Branch. A tidy little haunting.",
    "Root holds what feeds the question and what still grips the ground.",
    "Trunk sits in the middle of the mess. That is the living present, like it or not.",
    "Branch leans forward. Not a promise. More like a warning with good posture.",
    "Shuffle as usual. Let the deck loosen its secrets.",
    "Use the crank until the cards feel awake.",
    "Press A when you are ready to reveal all three.",
    "They appear from left to right. Root first, then Trunk, then Branch.",
    "After the reveal, I will walk you through each position one by one.",
    "Do not rush the middle card. It usually knows where the bruise is.",
    "When the reading ends, you can return and draw another spread."
}

class('HowToThreeCardScene').extends(BaseHowToScene)

function HowToThreeCardScene:init()
    HowToThreeCardScene.super.init(self, THREE_CARD_TEXTS)
end
