# Performance Plan

## Goal
Reduce the visible and audible hitch when entering spread game scenes and spread post scenes on Playdate hardware.

## Likely Hot Spots
- `BaseSpreadGameScene` scene entry work, especially the cloth swap and the first reveal phase.
- Card creation and per-card image caching in `drawCardsLogic()`.
- Reveal timing and audio bursts during `revealCardsSequentially()`.
- `BaseSpreadPostScene:init()`, especially text pagination, diary persistence, and animation setup.

## Preferred Approach
1. Keep the existing scene flow for now rather than splitting `showPlacementSprite()` into a separate scene.
2. Spread heavy work over a few frames instead of doing it all on the first reveal frame.
3. Preload or prewarm any reusable images or text assets before the transition point.
4. Delay nonessential sound effects by a frame or two if needed to reduce audible hitching.
5. Move any file I/O or expensive setup out of scene `init()` when possible, especially in the post scene.

## Experiments To Try
- Stage the cloth/background change first, then trigger card creation after a short delay.
- Create cards in small batches instead of all at once.
- Test whether removing or delaying reveal SFX reduces the audible drop even when the frame rate still dips.
- Move diary persistence out of `BaseSpreadPostScene:init()` and into a later moment if the post scene still hitches.

## Success Criteria
- No noticeable audio hiccup when entering the reveal section.
- No visible frame drop that stands out to the player on hardware.
- Post scene entry feels similarly smooth, even if the visual transition stays the same.
