#!/usr/bin/env python3
"""Rebuild characters/he/he_blockout.glb — ~1.8m civilian human mesh.

Capsule / sphere / tapered-limb meshes with embedded PBR-style textures.
Pose joints stay transform-only (`Hips`, `L_Fist`, …) so he.gd can drive
jab / heavy / roll / sprint. Collision stays on the capsule in he.tscn.

Origin at the feet, Y-up meters, Godot-forward (−Z face / fists).

Usage:
    python3 characters/he/build_he_blockout.py
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

OUT = Path(__file__).with_name("he_blockout.glb")

POSE_JOINTS = (
    "Hips",
    "Torso",
    "Head",
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
    b.add_material("coat", [0.86, 0.80, 0.70, 1.0], 0.78, texture="coat")
    b.add_material("shirt", [0.78, 0.88, 0.86, 1.0], 0.72, texture="shirt")
    b.add_material("pants", [0.72, 0.76, 0.88, 1.0], 0.84, texture="pants")
    b.add_material("skin", [0.96, 0.82, 0.70, 1.0], 0.52, texture="skin")
    b.add_material("hair", [0.55, 0.42, 0.34, 1.0], 0.88, texture="hair")
    b.add_material(
        "wrap",
        [1.0, 0.72, 0.58, 1.0],
        0.58,
        metal=0.02,
        emissive=[0.10, 0.02, 0.01],
        texture="wrap",
    )
    b.add_material("boot", [0.70, 0.62, 0.52, 1.0], 0.48, metal=0.06, texture="boot")
    b.add_material(
        "visor",
        [0.18, 0.32, 0.38, 0.92],
        0.18,
        metal=0.42,
        emissive=[0.10, 0.38, 0.42],
    )
    b.add_material("belt", [0.82, 0.64, 0.42, 1.0], 0.62, metal=0.04, texture="belt")
    b.add_material(
        "mark",
        [1.0, 0.42, 0.32, 1.0],
        0.40,
        emissive=[0.38, 0.06, 0.04],
        texture="mark",
    )
    b.add_material("eye", [0.95, 0.94, 0.90, 1.0], 0.22, texture="eye")
    b.add_material("iris", [0.16, 0.24, 0.26, 1.0], 0.28, texture="iris")
    b.add_material("cloth", [0.80, 0.74, 0.64, 1.0], 0.80, texture="coat", double_sided=True)


def _hand(b: GlbBuilder, prefix: str, sign: float) -> list[int]:
    kids = [
        b.mesh_node(f"{prefix}_FistMesh", translate_mesh(sphere("fist", 0.055, 12, 8), (0.0, -0.06, -0.03)), "wrap"),
        b.mesh_node(f"{prefix}_Palm", translate_mesh(ellipsoid("palm", 0.045, 0.035, 0.055, 10, 8), (0.0, -0.02, -0.02)), "wrap"),
    ]
    for i, x in enumerate((-0.028, -0.010, 0.010, 0.028)):
        finger = capsule(f"f{i}", 0.009, 0.085, 8, 3)
        kids.append(b.mesh_node(f"{prefix}_Finger{i}", translate_mesh(finger, (x, -0.12, -0.05)), "wrap"))
    thumb = rotate_mesh_z(capsule("thumb", 0.010, 0.062, 8, 3), 0.85 * sign)
    kids.append(b.mesh_node(f"{prefix}_Thumb", translate_mesh(thumb, (0.045 * sign, -0.05, -0.01)), "wrap"))
    return kids


def _head_bits(b: GlbBuilder) -> list[int]:
    bits = [
        b.mesh_node("HeadMesh", ellipsoid("head", 0.105, 0.118, 0.098, 16, 12), "skin"),
        b.mesh_node("Jaw", translate_mesh(ellipsoid("jaw", 0.078, 0.045, 0.070, 12, 8), (0.0, -0.04, -0.02)), "skin"),
        b.mesh_node("Nose", translate_mesh(ellipsoid("nose", 0.016, 0.022, 0.028, 8, 6), (0.0, 0.02, -0.10)), "skin"),
        b.mesh_node("EarL", translate_mesh(ellipsoid("el", 0.018, 0.032, 0.012, 8, 6), (-0.10, 0.02, 0.01)), "skin"),
        b.mesh_node("EarR", translate_mesh(ellipsoid("er", 0.018, 0.032, 0.012, 8, 6), (0.10, 0.02, 0.01)), "skin"),
        b.mesh_node("EyeL", translate_mesh(sphere("el", 0.016, 8, 6), (-0.034, 0.028, -0.086)), "eye"),
        b.mesh_node("EyeR", translate_mesh(sphere("er", 0.016, 8, 6), (0.034, 0.028, -0.086)), "eye"),
        b.mesh_node("IrisL", translate_mesh(sphere("il", 0.008, 7, 5), (-0.034, 0.028, -0.098)), "iris"),
        b.mesh_node("IrisR", translate_mesh(sphere("ir", 0.008, 7, 5), (0.034, 0.028, -0.098)), "iris"),
        b.mesh_node("Brow", translate_mesh(box("brow", (0.10, 0.012, 0.018)), (0.0, 0.055, -0.088)), "hair"),
        b.mesh_node("Mouth", translate_mesh(box("mouth", (0.046, 0.008, 0.012)), (0.0, -0.018, -0.092)), "wrap"),
        b.mesh_node("HairCap", translate_mesh(ellipsoid("hc", 0.114, 0.078, 0.110, 14, 8), (0.0, 0.108, 0.012)), "hair"),
        b.mesh_node("HairBack", translate_mesh(ellipsoid("hb", 0.095, 0.080, 0.070, 12, 8), (0.0, 0.04, 0.055)), "hair"),
        b.mesh_node("HairFringe", translate_mesh(ellipsoid("hf", 0.090, 0.032, 0.042, 10, 6), (0.0, 0.112, -0.055)), "hair"),
        b.mesh_node("Visor", translate_mesh(box("visor", (0.16, 0.028, 0.018)), (0.0, 0.036, -0.108)), "visor"),
    ]
    return bits


def build() -> bytes:
    b = GlbBuilder("line7/characters/he/build_he_blockout.py")
    _mats(b)

    l_fist = b.add_node("L_Fist", translation=(0.0, -0.34, 0.0), children=_hand(b, "L", -1.0))
    l_fore_mesh = b.mesh_node("L_ForearmMesh", translate_mesh(capsule("lf", 0.048, 0.30, 12, 4), (0.0, -0.14, -0.01)), "wrap")
    l_fore = b.add_node("L_Forearm", translation=(0.0, -0.30, 0.0), children=[l_fore_mesh, l_fist])
    l_up_mesh = b.mesh_node("L_UpperArmMesh", translate_mesh(capsule("lu", 0.046, 0.28, 12, 4), (0.0, -0.13, 0.0)), "coat")
    l_up = b.add_node("L_UpperArm", translation=(-0.22, 0.38, 0.0), children=[l_up_mesh, l_fore])

    r_fist = b.add_node("R_Fist", translation=(0.0, -0.34, 0.0), children=_hand(b, "R", 1.0))
    r_fore_mesh = b.mesh_node("R_ForearmMesh", translate_mesh(capsule("rf", 0.048, 0.30, 12, 4), (0.0, -0.14, -0.01)), "wrap")
    r_fore = b.add_node("R_Forearm", translation=(0.0, -0.30, 0.0), children=[r_fore_mesh, r_fist])
    r_up_mesh = b.mesh_node("R_UpperArmMesh", translate_mesh(capsule("ru", 0.046, 0.28, 12, 4), (0.0, -0.13, 0.0)), "coat")
    r_up = b.add_node("R_UpperArm", translation=(0.22, 0.38, 0.0), children=[r_up_mesh, r_fore])

    head = b.add_node("Head", translation=(0.0, 0.52, 0.0), children=_head_bits(b))
    neck = b.mesh_node("Neck", translate_mesh(capsule("neck", 0.042, 0.10, 10, 3), (0.0, 0.44, 0.0)), "skin")
    torso_mesh = b.mesh_node("TorsoMesh", translate_mesh(capsule("torso", 0.145, 0.46, 16, 5), (0.0, 0.20, 0.01)), "coat")
    chest = b.mesh_node("Chest", translate_mesh(ellipsoid("chest", 0.155, 0.14, 0.095, 14, 8), (0.0, 0.28, -0.01)), "coat")
    shirt = b.mesh_node("ShirtFront", translate_mesh(box("shirt", (0.16, 0.22, 0.03)), (0.0, 0.16, -0.10)), "shirt")
    collar = b.mesh_node("Collar", translate_mesh(cylinder("col", 0.08, 0.09, 0.06, 14, False), (0.0, 0.40, -0.01)), "coat")
    lapel_l = b.mesh_node("LapelL", translate_mesh(box("ll", (0.05, 0.26, 0.02)), (-0.05, 0.22, -0.12)), "shirt")
    lapel_r = b.mesh_node("LapelR", translate_mesh(box("lr", (0.05, 0.26, 0.02)), (0.05, 0.22, -0.12)), "shirt")
    mark = b.mesh_node("ChestMark", translate_mesh(box("mark", (0.05, 0.16, 0.02)), (0.07, 0.22, -0.125)), "mark")
    torso = b.add_node(
        "Torso",
        translation=(0.0, 0.10, 0.0),
        children=[torso_mesh, chest, shirt, collar, lapel_l, lapel_r, mark, neck, head, l_up, r_up],
    )

    l_foot = b.mesh_node("L_Foot", translate_mesh(ellipsoid("lf", 0.055, 0.038, 0.12, 10, 6), (0.0, -0.42, -0.04)), "boot")
    l_shin_mesh = b.mesh_node("L_ShinMesh", translate_mesh(capsule("ls", 0.048, 0.40, 12, 4), (0.0, -0.20, 0.0)), "pants")
    l_shin = b.add_node("L_Shin", translation=(0.0, -0.42, 0.0), children=[l_shin_mesh, l_foot])
    l_thigh_mesh = b.mesh_node("L_ThighMesh", translate_mesh(capsule("lt", 0.062, 0.40, 12, 4), (0.0, -0.18, 0.0)), "pants")
    l_thigh = b.add_node("L_Thigh", translation=(-0.10, -0.06, 0.0), children=[l_thigh_mesh, l_shin])

    r_foot = b.mesh_node("R_Foot", translate_mesh(ellipsoid("rf", 0.055, 0.038, 0.12, 10, 6), (0.0, -0.42, -0.04)), "boot")
    r_shin_mesh = b.mesh_node("R_ShinMesh", translate_mesh(capsule("rs", 0.048, 0.40, 12, 4), (0.0, -0.20, 0.0)), "pants")
    r_shin = b.add_node("R_Shin", translation=(0.0, -0.42, 0.0), children=[r_shin_mesh, r_foot])
    r_thigh_mesh = b.mesh_node("R_ThighMesh", translate_mesh(capsule("rt", 0.062, 0.40, 12, 4), (0.0, -0.18, 0.0)), "pants")
    r_thigh = b.add_node("R_Thigh", translation=(0.10, -0.06, 0.0), children=[r_thigh_mesh, r_shin])

    hips_mesh = b.mesh_node("HipsMesh", translate_mesh(ellipsoid("hips", 0.14, 0.08, 0.10, 14, 8), (0.0, 0.0, 0.0)), "pants")
    belt = b.mesh_node("Belt", translate_mesh(cylinder("belt", 0.155, 0.155, 0.055, 16, False), (0.0, 0.06, 0.0)), "belt")
    buckle = b.mesh_node("Buckle", translate_mesh(box("bk", (0.05, 0.04, 0.02)), (0.0, 0.06, -0.15)), "visor")
    coat_hem = b.mesh_node(
        "CoatHem",
        translate_mesh(rotate_mesh_x(plane("hem", 0.42, 0.38, 4), 0.35), (0.0, -0.22, 0.08)),
        "cloth",
    )
    hips = b.add_node(
        "Hips",
        translation=(0.0, 0.92, 0.0),
        children=[hips_mesh, belt, buckle, coat_hem, torso, l_thigh, r_thigh],
    )
    root = b.add_node("HEBlockout", children=[hips])

    names = {n["name"] for n in b.nodes}
    missing = [j for j in POSE_JOINTS if j not in names]
    if missing:
        raise RuntimeError(f"HE mesh missing pose joints: {missing}")
    for joint in POSE_JOINTS:
        node = next(n for n in b.nodes if n["name"] == joint)
        if "scale" in node or "mesh" in node:
            raise RuntimeError(f"Pose joint {joint} must be transform-only.")
    min_y, max_y = b.mesh_world_aabb()
    if min_y < -0.04 or min_y > 0.08:
        raise RuntimeError(f"Origin must sit at the feet (min Y={min_y:.3f})")
    if not (1.68 <= max_y <= 1.92):
        raise RuntimeError(f"HE height tip {max_y:.3f} m is outside 1.68–1.92")
    print(f"Verified HE rest AABB Y=[{min_y:.3f}, {max_y:.3f}]")
    return b.pack("HEBlockout", root)


def main() -> None:
    data = build()
    write_glb(OUT, data)
    print("Wrote ~1.80m civilian human mesh (capsule limbs, posed fists)")


if __name__ == "__main__":
    main()
