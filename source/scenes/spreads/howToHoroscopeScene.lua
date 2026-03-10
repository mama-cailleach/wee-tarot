local HOROSCOPE_TEXTS = {
    "Twelve cards for twelve houses. This one sprawls like a proper night sky.",
    "Use the horoscope spread when you want the whole weather report, not a single omen.",
    "Shuffle well. The zodiac does not reward lazy hands.",
    "Turn the crank until the deck feels alive and slightly judgmental.",
    "Press A to reveal the full wheel of the reading.",
    "Each card lands in a different house, touching a different part of your life.",
    "Some positions speak of love, work, home, fear, ambition. The usual human mess.",
    "This spread is broad by design. Let it show patterns before you chase details.",
    "After the reveal, I will guide you through the houses one by one.",
    "Bring a real question if you can. The stars are patient, but I am not."
}

class('HowToHoroscopeScene').extends(BaseHowToScene)

function HowToHoroscopeScene:init()
    HowToHoroscopeScene.super.init(self, HOROSCOPE_TEXTS)
end
