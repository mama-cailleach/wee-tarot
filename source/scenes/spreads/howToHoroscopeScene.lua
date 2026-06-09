local HOROSCOPE_TEXTS = {
    "Twelve cards. A massive undertaking. The Zodiac Horoscope.", 
    "We are charting the entire sky around you.", 
    "Laying out the twelve houses of the great celestial wheel.",
    "A wee lassie named Saori once told me a tale...", 
    "Something about twelve golden temples and knigths saving a goddess.",
    "Absolute nonsense! Nobody is running anywhere here.",
    "Charting the sky requires you to sit still and look inward,", 
    "not go charging up staircases in the name of Athena.",
    "Each card represents a house, a zodiac sign, a ruling planet...",
    "If you are one of those who know your own astral map,", 
    "you can use this reading to unlock deeper meanings.", 
    "Focus on your own sun sign, or look at where the stars are sitting this very month",
    "First is Aries. The House of Identity.", 
    "Your core personality, your outward ego, where your feet stand in the light.",
    "Second is Taurus. The House of Resources.", 
    "Your material possessions, how you earn your daily bread, your true self-worth.",
    "Third is Gemini. The House of Communication.", 
    "Your intellect, how you talk to the world, your siblings, your local networks.",
    "Fourth is Cancer. The House of Home and Family.", 
    "Your roots, your domestic life,  the private space where you retreat to hide.",
    "Fifth is Leo. The House of Creativity.", 
    "Your self-expression, romance, recreation, the joy of taking a proper gamble.",
    "Sixth is Virgo. The House of the Grind.", 
    "Your daily routines, responsibilities, physical health, mundane work.",
    "Seventh is Libra. The House of Partnerships.", 
    "Committed relationships, legal bonds, or those who openly oppose you.",
    "Eighth is Scorpio. The Deep Water.", 
    "Joint resources, secrets, mortality, the heavy price to pay behind closed doors.",
    "Ninth is Sagittarius. The Long Road.", 
    "Higher education, long travel, your philosophy, expanding mental horizons.",
    "Tenth is Capricorn. The Peak.", 
    "Your public reputation, career, legacy, how the world judges your success.",
    "Eleventh is Aquarius. The Collective.", 
    "Your friendships, community, social networks, your highest aspirations.",
    "And twelfth is Pisces. The House of Self-Undoing.", 
    "The subconscious, your private secrets, karmic lessons...", 
    "The strange ways you get in your own way.",
    "It's a massive sky to lay out on a small cloth.", 
    "Let the stars find their alignment in your hands.",
    "Well? The stars aren't going to move themselves.",
    "Bring a real question if you can. The cosmos is patient, but I am not."
}

class('HowToHoroscopeScene').extends(BaseHowToScene)

function HowToHoroscopeScene:init()
    HowToHoroscopeScene.super.init(self, HOROSCOPE_TEXTS)
end
