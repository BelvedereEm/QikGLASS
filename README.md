# QikGLASS
Stained Glass Scorer using CNC 3018

A spring-loaded, self-steering glass-scoring head that drops into the spindle clamp of a **CNCTOPBAOS 3018-PRO** (GRBL, offline controller), carrying a carbide wheel head from a **QWORK 2–20 mm oil-feed glass cutter**. Swap the 775 spindle out, drop the head in, and score stained-glass patterns straight from an SVG.

**Live tool:** https://belvedereem.github.io/QikGLASS/

![Exploded view of the scoring head](images/scoring-head-exploded.png)

## What's here

| Path | What it is |
|---|---|
| `index.html` | **Pattern → G-code** tool plus the build and calibration guide. Lays the job out on a 6 × 4 in glass blank, adds relief scores around curves and corners, and saves a `.nc` file for the controller. |
| `trace.html` | **PNG → SVG**: open a picture of a pattern (black lines on white), set its real size, and trace every enclosed area into a piece outline. Flags pieces that won't fit a 6 × 4 in blank. |
| `select.html` | **Select parts**: open a full pattern SVG, click or box-select just the lines you want, set their cutting order, and send them to the G-code page |
| `cad/qikglass_scoring_head.scad` | Parametric OpenSCAD source for all printed parts |
| `stl/` | Printable parts at the default dimensions: body, cap, carrier, glass corner fence (print 2) |
| `images/` | Renders |

## How it works

- **Body** sits in the spindle clamp and holds two LM8UU linear bearings.
- An **8 mm shaft** slides up/down and spins freely in the bearings.
- A **compression spring** between the body and the carrier sets the scoring pressure (about 3–5 kg), so small bed and glass height errors barely change the force.
- The **carrier** holds the QWORK cutter head (removed from its handle) **1.5 mm off-centre**, so the wheel trails like a caster and steers itself around curves. The G-code tool compensates every path for that offset.
- Before each score the wheel takes a short **alignment stroke on a scrap glass pad** so it touches down already pointing the right way.

## Before you print: measure two things

The defaults are estimates. Set these at the top of the `.scad` file, then export STLs from [OpenSCAD](https://openscad.org):

- `clamp_d`: diameter of the spindle motor where the clamp grips it (bare 775 ≈ 42 mm, across the flux ring ≈ 45.5 mm)
- `head_shank_d`: diameter of the cutter head's shank that sits inside the handle

## Parts

| Qty | Part |
|---|---|
| 2 | LM8UU linear bearing |
| 1 | 8 mm hardened rod, 100 mm |
| 1 | 8 mm shaft collar |
| 1 | Compression spring: ID ≥ 9 mm, OD ≤ 13 mm, free length 25–30 mm, wire 1.0–1.2 mm |
| 3 | M3 × 8 countersunk screw (cap) |
| 2 | M3 × 10 socket screw (carrier clamps, self-tapping into plastic) |
| 1 | QWORK 2–6 mm cutter head |
| – | MDF board + 2–3 mm felt or cork bed, glass cutting oil, kitchen scale |

Print in PETG or PLA+, 0.2 mm layers, 4 walls, 40 % infill. If the bearings are loose or tight, tune `lm_fit`.

## Relief scores

Glass won't break cleanly around a circle, a semicircle or a deep inside curve on its own. For every closed piece, the G-code page can add relief scores that run out to the edge of the 6 × 4 blank:

- **Circles and outside curves:** a pinwheel of tangent lines, each touching the curve and running to the glass edge.
- **Sharp outside corners:** the side is extended past the corner to the edge.
- **Inside curves (bites):** a comb of parallel lines out through the mouth of the curve.

Relief lines are scored after the outline and stop where they meet it, so nothing crosses. Break the relief pieces first, nearest the edge first, and then the piece. Set the density to Light, Normal or Dense.

## Quick workflow

1. Unplug the spindle, swap in the scoring head, and zero Z on the glass surface (paper-pinch test).
2. Find **score depth** with a kitchen scale: jog down past first contact until it reads about 3 kg.
3. Get a pattern: trace a PNG in `trace.html`, or draw closed piece outlines or score lines in Inkscape (in mm).
4. In `select.html`, click the piece or pieces to cut from one 6 × 4 in blank and choose **Send to QikGLASS**. The G-code page centres them on the blank and adds relief scores. Check the warnings, then save the `.nc` file.
5. Oil the wheel, push the blank into the corner fence, run the file, break the relief pieces, then run the outline.

Full build, calibration and safety notes are in the page's **Build the head** and **Calibrate & score** tabs.

> ⚠️ Never run a milling file with the glass head fitted, and keep glass files in their own folder on the SD card. The generated files include `M5` and never start the spindle.

## Status

Design stage. The G-code tool has been tested in a browser. The printed head has not been built or run on a machine yet, so expect to tune fits, the spring and the pressure.
