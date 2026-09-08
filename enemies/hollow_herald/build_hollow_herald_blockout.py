#!/usr/bin/env python3
"""Rebuild enemies/hollow_herald/hollow_herald_blockout.glb — official Jake path.

~2.05 m lesser-demon transit-coat humanoid. Capsule / sphere / tapered meshes
with embedded cloth / hollow-skin textures. Pose joints stay transform-only
(`Hips`, `Torso`, `R_UpperArm`, `Crown`, …) so swipe / lunge clocks keep
working. Capsule collision is unchanged in hollow_herald.tscn.

Origin at the feet, Y-up meters, Godot-forward (−Z visor / lapels / fists).

Usage:
    python3 enemies/hollow_herald/build_hollow_herald_blockout.py
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools"))

from glb_kit import (  # noqa: E402
    GlbBuilder,
    box,
    capsule,
    cylinder,
    ellipsoid,
    plane,
    rotate_mesh_x,
    rotate_mesh_z,
    sphere,
    translate_mesh,
    write_glb,
)

OUT = Path(__file__).with_name("hollow_herald_blockout.glb")

POSE_JOINTS = (
    "Hips",
    "Torso",
    "Head",
    "Crown",
    "L_UpperArm",
    "L_Forearm",
    "L_Fist",
    "R_UpperArm",
    "R_Forearm",
    "R_Fist",
    "L_Thigh",
    "L_Shin",
    "R_Thigh",
    "R_Shin",
)


def _mats(b: GlbBuilder) -> None:
    b.add_material("coat", [0.82, 0.80, 0.90, 1.0], 0.70, metal=0.06, texture="herald_coat")
    b.add_material(
        "lining",
        [1.0, 0.42, 0.38, 1.0],
        0.54,
        emissive=[0.18, 0.03, 0.03],
        texture="lining",
        double_sided=True,
    )
    b.add_material("pants", [0.55, 0.52, 0.62, 1.0], 0.86, texture="pants")
    b.add_material("hollow", [0.92, 0.86, 0.80, 1.0], 0.58, texture="hollow")
    b.add_material(
        "gauntlet",
        [0.88, 0.68, 0.66, 1.0],
        0.40,
        metal=0.14,
        emissive=[0.10, 0.03, 0.03],
        texture="gauntlet",
    )
    b.add_material(
        "claw",
        [0.92, 0.84, 0.68, 1.0],
        0.26,
        metal=0.22,
        emissive=[0.16, 0.06, 0.03],
        texture="crown",
    )
    b.add_material(
        "crown",
        [0.95, 0.85, 0.50, 1.0],
        0.32,
        metal=0.48,
        emissive=[0.26, 0.16, 0.04],
        texture="crown",
    )
    b.add_material(
        "brass",
        [0.90, 0.74, 0.42, 1.0],
        0.38,
        metal=0.42,
        emissive=[0.06, 0.04, 0.01],
        texture="brass",
    )
    b.add_material(
        "void",
        [0.08, 0.06, 0.08, 1.0],
        0.16,
        metal=0.22,
        emissive=[0.12, 0.05, 0.03],
        texture="void",
    )
    b.add_material("boot", [0.50, 0.42, 0.38, 1.0], 0.50, metal=0.08, texture="boot")
    b.add_material(
        "mark",
        [0.95, 0.32, 0.30, 1.0],
        0.36,
        emissive=[0.26, 0.04, 0.03],
        texture="mark",
    )
    b.add_material("cloth", [0.78, 0.76, 0.86, 1.0], 0.76, texture="herald_coat", double_sided=True)


def _claws(b: GlbBuilder, prefix: str) -> list[int]:
    kids = []
    for i, (x, z, h) in enumerate(((-0.05, -0.12, 0.20), (0.0, -0.16, 0.24), (0.05, -0.12, 0.20))):
        claw = capsule(f"{prefix}c{i}", 0.012, h, 8, 3)
        kids.append(b.mesh_node(f"{prefix}_Claw{i+1}", translate_mesh(claw, (x, -0.18, z)), "claw"))
    return kids


def _gauntlet_hand(b: GlbBuilder, prefix: str, bulky: bool) -> list[int]:
    r = 0.072 if bulky else 0.062
    kids = [
        b.mesh_node(f"{prefix}_FistMesh", translate_mesh(sphere("fist", r, 12, 8), (0.0, -0.08, -0.04)), "gauntlet"),
        b.mesh_node(f"{prefix}_Knuckle", translate_mesh(ellipsoid("kn", r * 1.05, 0.04, r * 0.9, 10, 6), (0.0, -0.02, -0.02)), "gauntlet"),
    ]
    kids.extend(_claws(b, prefix))
    return kids


def _crown_bits(b: GlbBuilder) -> list[int]:
    band = b.mesh_node("CrownBand", translate_mesh(cylinder("band", 0.11, 0.11, 0.045, 16, False), (0.0, 0.02, 0.0)), "crown")
    brim = b.mesh_node("TransitBrim", translate_mesh(cylinder("brim", 0.14, 0.13, 0.018, 16, True), (0.0, 0.00, -0.02)), "brass")
    horns = []
    for name, x, tilt in (("CrownHornL", -0.08, 0.35), ("CrownHornC", 0.0, 0.0), ("CrownHornR", 0.08, -0.35)):
        horn = rotate_mesh_z(cylinder(name.lower(), 0.008, 0.022, 0.18, 8, True), tilt)
        horns.append(b.mesh_node(name, translate_mesh(horn, (x, 0.12, 0.02)), "crown"))
    return [band, brim, *horns]


def _head_bits(b: GlbBuilder) -> list[int]:
    crown = b.add_node("Crown", translation=(0.0, 0.18, 0.0), children=_crown_bits(b))
    return [
        b.mesh_node("HeadMesh", ellipsoid("head", 0.108, 0.120, 0.100, 16, 12), "hollow"),
        b.mesh_node("CheekL", translate_mesh(ellipsoid("cl", 0.04, 0.05, 0.035, 8, 6), (-0.07, -0.02, -0.04)), "hollow"),
        b.mesh_node("CheekR", translate_mesh(ellipsoid("cr", 0.04, 0.05, 0.035, 8, 6), (0.07, -0.02, -0.04)), "hollow"),
        b.mesh_node("VoidVisor", translate_mesh(box("visor", (0.16, 0.042, 0.022)), (0.0, 0.04, -0.102)), "void"),
        b.mesh_node("SocketL", translate_mesh(sphere("sl", 0.018, 8, 6), (-0.034, 0.03, -0.09)), "void"),
        b.mesh_node("SocketR", translate_mesh(sphere("sr", 0.018, 8, 6), (0.034, 0.03, -0.09)), "void"),
        crown,
    ]


def build() -> bytes:
    b = GlbBuilder("line7/enemies/hollow_herald/build_hollow_herald_blockout.py")
    _mats(b)

    l_fist = b.add_node("L_Fist", translation=(0.0, -0.40, 0.0), children=_gauntlet_hand(b, "L", False))
    l_fore_mesh = b.mesh_node("L_ForearmMesh", translate_mesh(capsule("lf", 0.058, 0.36, 12, 4), (0.0, -0.16, -0.01)), "gauntlet")
    l_fore = b.add_node("L_Forearm", translation=(0.0, -0.36, 0.0), children=[l_fore_mesh, l_fist])
    l_up_mesh = b.mesh_node("L_UpperArmMesh", translate_mesh(capsule("lu", 0.058, 0.34, 12, 4), (0.0, -0.16, 0.0)), "coat")
    l_ep = b.mesh_node("L_Epaulette", translate_mesh(ellipsoid("le", 0.08, 0.03, 0.07, 10, 6), (0.0, 0.02, 0.0)), "brass")
    l_up = b.add_node("L_UpperArm", translation=(-0.28, 0.40, 0.0), children=[l_up_mesh, l_ep, l_fore])

    r_fist = b.add_node("R_Fist", translation=(0.0, -0.42, 0.0), children=_gauntlet_hand(b, "R", True))
    r_fore_mesh = b.mesh_node("R_ForearmMesh", translate_mesh(capsule("rf", 0.062, 0.40, 12, 4), (0.0, -0.18, -0.02)), "gauntlet")
    r_fore = b.add_node("R_Forearm", translation=(0.0, -0.38, 0.0), children=[r_fore_mesh, r_fist])
    r_up_mesh = b.mesh_node("R_UpperArmMesh", translate_mesh(capsule("ru", 0.062, 0.36, 12, 4), (0.0, -0.17, 0.0)), "coat")
    r_ep = b.mesh_node("R_Epaulette", translate_mesh(ellipsoid("re", 0.08, 0.03, 0.07, 10, 6), (0.0, 0.02, 0.0)), "brass")
    r_up = b.add_node("R_UpperArm", translation=(0.28, 0.40, 0.0), children=[r_up_mesh, r_ep, r_fore])

    head = b.add_node("Head", translation=(0.0, 0.50, 0.0), children=_head_bits(b))
    neck = b.mesh_node("Neck", translate_mesh(capsule("neck", 0.048, 0.11, 10, 3), (0.0, 0.44, 0.0)), "hollow")
    torso_mesh = b.mesh_node("TorsoMesh", translate_mesh(capsule("torso", 0.175, 0.50, 16, 5), (0.0, 0.20, 0.02)), "coat")
    chest = b.mesh_node("Chest", translate_mesh(ellipsoid("chest", 0.185, 0.16, 0.12, 14, 8), (0.0, 0.26, 0.0)), "coat")
    collar = b.mesh_node("Collar", translate_mesh(cylinder("col", 0.10, 0.12, 0.08, 14, False), (0.0, 0.42, -0.01)), "coat")
    lapel_l = b.mesh_node("LapelL", translate_mesh(box("ll", (0.07, 0.30, 0.025)), (-0.06, 0.20, -0.13)), "lining")
    lapel_r = b.mesh_node("LapelR", translate_mesh(box("lr", (0.07, 0.30, 0.025)), (0.06, 0.20, -0.13)), "lining")
    mark = b.mesh_node("ChestMark", translate_mesh(box("mk", (0.07, 0.18, 0.02)), (0.0, 0.16, -0.145)), "mark")
    buttons = []
    for i, (x, y) in enumerate(((-0.035, 0.26), (0.035, 0.26), (-0.035, 0.16), (0.035, 0.16))):
        buttons.append(b.mesh_node(f"Button{i}", translate_mesh(sphere(f"b{i}", 0.016, 8, 6), (x, y, -0.135)), "brass"))
    torso = b.add_node(
        "Torso",
        translation=(0.0, 0.10, 0.0),
        children=[torso_mesh, chest, collar, lapel_l, lapel_r, mark, neck, head, l_up, r_up, *buttons],
    )

    l_foot = b.mesh_node("L_Foot", translate_mesh(ellipsoid("lf", 0.058, 0.04, 0.13, 10, 6), (0.0, -0.44, -0.05)), "boot")
    l_shin_mesh = b.mesh_node("L_ShinMesh", translate_mesh(capsule("ls", 0.052, 0.40, 12, 4), (0.0, -0.20, 0.0)), "pants")
    l_shin = b.add_node("L_Shin", translation=(0.0, -0.44, 0.0), children=[l_shin_mesh, l_foot])
    l_thigh_mesh = b.mesh_node("L_ThighMesh", translate_mesh(capsule("lt", 0.068, 0.40, 12, 4), (0.0, -0.18, 0.0)), "pants")
    l_thigh = b.add_node("L_Thigh", translation=(-0.11, -0.06, 0.0), children=[l_thigh_mesh, l_shin])

    r_foot = b.mesh_node("R_Foot", translate_mesh(ellipsoid("rf", 0.058, 0.04, 0.13, 10, 6), (0.0, -0.44, -0.05)), "boot")
    r_shin_mesh = b.mesh_node("R_ShinMesh", translate_mesh(capsule("rs", 0.052, 0.40, 12, 4), (0.0, -0.20, 0.0)), "pants")
    r_shin = b.add_node("R_Shin", translation=(0.0, -0.44, 0.0), children=[r_shin_mesh, r_foot])
    r_thigh_mesh = b.mesh_node("R_ThighMesh", translate_mesh(capsule("rt", 0.068, 0.40, 12, 4), (0.0, -0.18, 0.0)), "pants")
    r_thigh = b.add_node("R_Thigh", translation=(0.11, -0.06, 0.0), children=[r_thigh_mesh, r_shin])

    hips_mesh = b.mesh_node("HipsMesh", translate_mesh(ellipsoid("hips", 0.16, 0.08, 0.11, 14, 8), (0.0, 0.0, 0.0)), "pants")
    belt = b.mesh_node("Belt", translate_mesh(cylinder("belt", 0.175, 0.175, 0.055, 16, False), (0.0, 0.07, 0.0)), "brass")
    coat_back = b.mesh_node(
        "CoatBack",
        translate_mesh(rotate_mesh_x(plane("back", 0.52, 0.95, 5), 0.18), (0.0, -0.42, 0.14)),
        "cloth",
    )
    coat_l = b.mesh_node(
        "CoatFlareL",
        translate_mesh(rotate_mesh_z(rotate_mesh_x(plane("fl", 0.22, 0.88, 4), 0.12), 0.25), (-0.22, -0.40, 0.04)),
        "cloth",
    )
    coat_r = b.mesh_node(
        "CoatFlareR",
        translate_mesh(rotate_mesh_z(rotate_mesh_x(plane("fr", 0.22, 0.88, 4), 0.12), -0.25), (0.22, -0.40, 0.04)),
        "cloth",
    )
    hem = b.mesh_node("HemLining", translate_mesh(box("hem", (0.40, 0.10, 0.06)), (0.0, -0.86, 0.08)), "lining")
    hips = b.add_node(
        "Hips",
        translation=(0.0, 1.02, 0.0),
        children=[hips_mesh, belt, coat_back, coat_l, coat_r, hem, torso, l_thigh, r_thigh],
    )
    root = b.add_node("HeraldBlockout", children=[hips])

    names = {n["name"] for n in b.nodes}
    missing = [j for j in POSE_JOINTS if j not in names]
    if missing:
        raise RuntimeError(f"Official mesh missing pose joints: {missing}")
    for joint in POSE_JOINTS:
        node = next(n for n in b.nodes if n["name"] == joint)
        if "scale" in node or "mesh" in node:
            raise RuntimeError(f"Pose joint {joint} must be transform-only.")
    min_y, max_y = b.mesh_world_aabb()
    if min_y < -0.04 or min_y > 0.08:
        raise RuntimeError(f"Origin must sit at the feet (min Y={min_y:.3f})")
    if not (2.00 <= max_y <= 2.14):
        raise RuntimeError(f"Crown tip must be 2.00–2.14 m (max Y={max_y:.3f})")
    print(f"Verified Herald rest AABB Y=[{min_y:.3f}, {max_y:.3f}] height={max_y - min_y:.3f}m")
    return b.pack("HeraldBlockout", root)


def main() -> None:
    data = build()
    write_glb(OUT, data)
    print("Wrote official ~2.05m lesser-demon transit-coat humanoid")


if __name__ == "__main__":
    main()
