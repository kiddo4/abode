# Third-party assets

Every bundled asset is public domain (CC0) or openly licensed. No attribution is
legally required for the CC0 items; it is given here because it is the decent
thing to do.

## 3D models

**Kenney City Kit (Suburban)** — `assets/models/exterior/`
CC0 1.0 Universal. https://kenney.nl/assets/city-kit-suburban

The exterior houses. These GLBs originally referenced a shared external texture
(`Textures/colormap.png`), which Glint cannot load — it reads embedded textures
only, so the models rendered untextured. `tool/embed_glb_textures.py` inlines the
colormap into each GLB so every model is self-contained.

**Kenney Furniture Kit** — `assets/models/kit/`
CC0 1.0 Universal. https://kenney.nl/assets/furniture-kit

140 models. Supplies both the interior structure (`wall`, `wallDoorway`,
`wallWindow`, `floorFull`, `stairs`, `doorway`) and the furnishings. Materials are
untextured `baseColorFactor` batches, which suits Glint well — it has no normal or
ORM map support, so flat-shaded low-poly kits are the right fit rather than a
compromise.

## Environment

**Poly Haven — Studio Small 09** — `assets/hdri/studio_small_09_1k.hdr`
CC0 1.0 Universal. https://polyhaven.com/a/studio_small_09

Equirectangular HDRI driving image-based lighting. The 1k variant is used rather
than 2k: irradiance and specular prefiltering happen at load, and 1k is ample for
real-time IBL at this scale.

## Fonts

**Fraunces** — `assets/fonts/Fraunces.ttf`
SIL Open Font License 1.1. https://github.com/google/fonts/tree/main/ofl/fraunces

**Inter** — `assets/fonts/Inter.ttf`
SIL Open Font License 1.1. https://github.com/google/fonts/tree/main/ofl/inter

Both are bundled as variable TTFs rather than fetched at runtime, so the app has
no network dependency for text.
