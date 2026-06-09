local THREE_CARD_TEXTS = {
    "Ah, looking for a bit more weight to your questions, are you?",
    "We call this one the Root, Trunk, and Branch.", 
    "A three-card layout, woven tight like the old Celtic Tree of Life.",
    "Some folks prefer the tidy names: Past, Present, and Future.", 
    "Or as I like to call them... Afore, The Noo, and Efter.",
    "But I prefer the woods. A three-card read... or a tree-card read,",
    "They sound the same, and nature's a far better teacher anyway.",
    "The first card is the Root. It sits in the heavy, dark, damp earth.",
    "It speaks of your hidden histories, your foundations...", 
    "and the things you've buried deep that are still very much alive.",
    "The second is the Trunk.", 
    "The weather-beaten endurance of the here and now.",
    "It's the weight of the moment, the thick bark,", 
    "and how you're holding steady against the gale.",
    "And the third, the Branch.", 
    "The reach into the shifting wind, the vulnerability of new growth,", 
    "and whatever is waiting for you on the grey horizon.",
    "Shuffle the deck. Let the wood smoke settle in your mind.",
    "See how the branches lean back toward the roots.",
    "Well? Don't just stand there like a big old trunk.",
    "Away you go!"
}

class('HowToThreeCardScene').extends(BaseHowToScene)

function HowToThreeCardScene:init()
    HowToThreeCardScene.super.init(self, THREE_CARD_TEXTS)
end
