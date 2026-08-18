# Abode

A real estate marketplace where every listing is live 3D geometry rendered by
[Glint](https://github.com/kiddo4/glint) inside the Flutter widget tree — orbit
the exterior, then walk through the interior.

Built to demonstrate that real-time 3D is viable in Flutter, wrapped in an app
that stands on its own rather than a viewer with buttons attached.

## Running it

```bash
flutter run
```

iOS and Android only. Glint renders through Flutter GPU, which has no Web,
Windows, or Linux support yet. **Android needs a physical Vulkan-capable
device** — emulators abort natively rather than falling back.

The Flutter GPU flags are already baked into `ios/Runner/Info.plist` and
`android/app/src/main/AndroidManifest.xml`, so no run flags are needed.

## What each screen demonstrates

| Screen | Glint surface |
| --- | --- |
| **Discover** | A vertical feed of live `Scene3D` viewports. Horizontal drags orbit the house, vertical drags page the feed — `GlintGestureMode.scrollAware` routing both from one viewport. |
| **Detail** | Orbit with `DirectionalLight` + `EnvironmentLight` HDRI, and `Label3D` hotspots pinned to points on the model with occlusion fading. |
| **Interior** | `GlintGameView` with a free `GlintGameCamera`: a dollhouse plan view that drops the ceiling, and first-person room-to-room navigation with eased camera glides. |

## Architecture notes

**Two rendering paths, by necessity.** `Scene3D` renders only the *first* model
node it finds, so it suits one-model-per-viewport listing pages. A room built
from ~90 kit pieces has to go through `GlintGameView`, which also supplies the
free camera the walkthrough needs.

**One live viewport at a time.** The Discover feed mounts a `Scene3D` only for
the settled page; neighbours render a typographic placeholder. A list of
simultaneously live GPU viewports is the obvious build and the wrong one.

**Interiors are composed, not modelled.** `lib/data/interior/` describes floor
plans as grid placements of Kenney kit pieces (`PlanBuilder.floor`, `.wallX`,
`.wallZ`, `.ceiling`) which become `GlintGameInstance`s. The kit is internally
consistent but *not* metric — a sofa is 0.98 units against a 1.29-unit wall — so
pieces are placed at native scale and eye height is derived from that same
proportion rather than from metres.

**Design.** Editorial and deliberately gradient-free: depth comes from
whitespace, hairline rules, and the liquid-glass chrome floating above the 3D.
All tokens live in `lib/app/theme.dart`; the accent is a single colour.

## Assets

All CC0 or OFL. See [ATTRIBUTION.md](ATTRIBUTION.md).

`tool/embed_glb_textures.py` inlines external texture URIs into a `.glb`. Kenney
kits reference a shared `Textures/colormap.png` next to the model, and Glint
reads embedded textures only — copied on their own those models render
untextured. Any Kenney kit used with Glint needs this pass.

## Engine dependency

Pinned via `dependency_overrides` to a local checkout of `glint_engine` carrying
fixes not yet on pub.dev — the Flutter GPU API migration, an Impeller v2 shader
bundle, and a `Label3D` first-frame fix. Drop the override once those ship.
