#!/usr/bin/env python3
"""Rebuild enemies/hollow_herald/hollow_herald_blockout.glb — official Jake path.

Humanoid lesser-demon blockout, ~2.05 m to the crown tip, transit-coat bulk,
loud wind-up arms with clawed fists. Joint names match the temp
herald_blockout.glb so Andrew can swap the preload without pose rework.

Hierarchy is joint nodes (no scale) with mesh children (scale = box size).
Origin at the feet, Y-up meters, +Z glTF forward (Godot imports that as -Z).

This does **not** replace the wired temp. hollow_herald.tscn / .gd still
instance herald_blockout.glb until Andrew swaps the path.

Usage:
    python3 enemies/hollow_herald/build_hollow_herald_blockout.py
"""

from __future__ import annotations

import json
import struct
from pathlib import Path

OUT = Path(__file__).with_name("hollow_herald_blockout.glb")

# Pose joints hollow_herald.gd already looks up on the temp.
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

MATERIALS = {
    ## Ashen transit coat — lesser-demon, still reads in the dim undercroft.
    "coat": {"color": [0.50, 0.48, 0.58, 1.0], "rough": 0.72, "metal": 0.08},
    "lining": {
        "color": [0.48, 0.16, 0.18, 1.0],
        "rough": 0.56,
        "metal": 0.0,
        "emissive": [0.22, 0.04, 0.04],
    },
    "pants": {"color": [0.22, 0.20, 0.26, 1.0], "rough": 0.86, "metal": 0.0},
    "hollow": {"color": [0.70, 0.62, 0.56, 1.0], "rough": 0.60, "metal": 0.0},
    "gauntlet": {
        "color": [0.46, 0.32, 0.34, 1.0],
        "rough": 0.42,
        "metal": 0.16,
        "emissive": [0.16, 0.05, 0.05],
    },
    "claw": {
        "color": [0.78, 0.70, 0.58, 1.0],
        "rough": 0.28,
        "metal": 0.22,
        "emissive": [0.20, 0.08, 0.04],
    },
    "crown": {
        "color": [0.76, 0.66, 0.38, 1.0],
        "rough": 0.34,
        "metal": 0.50,
        "emissive": [0.32, 0.22, 0.06],
    },
    "brass": {
        "color": [0.66, 0.52, 0.30, 1.0],
        "rough": 0.42,
        "metal": 0.40,
        "emissive": [0.08, 0.05, 0.01],
    },
    "void": {
        "color": [0.06, 0.05, 0.07, 1.0],
        "rough": 0.20,
        "metal": 0.20,
        "emissive": [0.16, 0.08, 0.04],
    },
    "boot": {"color": [0.12, 0.10, 0.10, 1.0], "rough": 0.54, "metal": 0.10},
    "mark": {
        "color": [0.54, 0.16, 0.18, 1.0],
        "rough": 0.38,
        "metal": 0.0,
        "emissive": [0.30, 0.05, 0.04],
    },
}


def unit_cube() -> tuple[list[float], list[float], list[int]]:
    faces = [
        ((0.5, -0.5, -0.5), (0.5, 0.5, -0.5), (0.5, 0.5, 0.5), (0.5, -0.5, 0.5), (1, 0, 0)),
        ((-0.5, -0.5, 0.5), (-0.5, 0.5, 0.5), (-0.5, 0.5, -0.5), (-0.5, -0.5, -0.5), (-1, 0, 0)),
        ((-0.5, 0.5, -0.5), (-0.5, 0.5, 0.5), (0.5, 0.5, 0.5), (0.5, 0.5, -0.5), (0, 1, 0)),
        ((-0.5, -0.5, 0.5), (-0.5, -0.5, -0.5), (0.5, -0.5, -0.5), (0.5, -0.5, 0.5), (0, -1, 0)),
        ((-0.5, -0.5, 0.5), (0.5, -0.5, 0.5), (0.5, 0.5, 0.5), (-0.5, 0.5, 0.5), (0, 0, 1)),
        ((0.5, -0.5, -0.5), (-0.5, -0.5, -0.5), (-0.5, 0.5, -0.5), (0.5, 0.5, -0.5), (0, 0, -1)),
    ]
    positions: list[float] = []
    normals: list[float] = []
    indices: list[int] = []
    for a, b, c, d, n in faces:
        base = len(positions) // 3
        for p in (a, b, c, d):
            positions.extend(p)
            normals.extend(n)
        indices.extend((base, base + 1, base + 2, base, base + 2, base + 3))
    return positions, normals, indices


def pack_f32(values: list[float]) -> bytes:
    return struct.pack(f"<{len(values)}f", *values)


def pack_u16(values: list[int]) -> bytes:
    return struct.pack(f"<{len(values)}H", *values)


def align4(buf: bytearray) -> None:
    while len(buf) % 4:
        buf.append(0)


def minmax(values: list[float], stride: int) -> tuple[list[float], list[float]]:
    mins = list(values[:stride])
    maxs = list(values[:stride])
    for i in range(0, len(values), stride):
        for k in range(stride):
            mins[k] = min(mins[k], values[i + k])
            maxs[k] = max(maxs[k], values[i + k])
    return mins, maxs


def node(
    name: str,
    translation: tuple[float, float, float] | None = None,
    scale: tuple[float, float, float] | None = None,
    mesh: int | None = None,
    children: list[int] | None = None,
) -> dict:
    out: dict = {"name": name}
    if translation is not None:
        out["translation"] = [round(v, 5) for v in translation]
    if scale is not None:
        out["scale"] = [round(v, 5) for v in scale]
    if mesh is not None:
        out["mesh"] = mesh
    if children:
        out["children"] = children
    return out


def _world_of(nodes: list[dict], idx: int) -> tuple[tuple[float, float, float], tuple[float, float, float]]:
    """Rest-pose world translation and scale (no rotations in this GLB)."""
    chain: list[int] = []
    parent_of: dict[int, int] = {}
    for i, n in enumerate(nodes):
        for child in n.get("children", []):
            parent_of[child] = i
    cur = idx
    while True:
        chain.append(cur)
        if cur not in parent_of:
            break
        cur = parent_of[cur]
    tx = ty = tz = 0.0
    sx = sy = sz = 1.0
    for i in reversed(chain):
        n = nodes[i]
        t = n.get("translation", [0.0, 0.0, 0.0])
        s = n.get("scale", [1.0, 1.0, 1.0])
        tx += t[0] * sx
        ty += t[1] * sy
        tz += t[2] * sz
        sx *= s[0]
        sy *= s[1]
        sz *= s[2]
    return (tx, ty, tz), (sx, sy, sz)


def verify_nodes(nodes: list[dict]) -> tuple[float, float]:
    names = {n["name"] for n in nodes}
    missing = [j for j in POSE_JOINTS if j not in names]
    if missing:
        raise RuntimeError(f"Official blockout missing pose joints: {missing}")
    for joint in POSE_JOINTS:
        idx = next(i for i, n in enumerate(nodes) if n["name"] == joint)
        if "scale" in nodes[idx]:
            raise RuntimeError(f"Pose joint {joint} must not carry scale (pose squash).")
        if "mesh" in nodes[idx]:
            raise RuntimeError(f"Pose joint {joint} must be a transform-only node.")

    min_y = 1e9
    max_y = -1e9
    for i, n in enumerate(nodes):
        if "mesh" not in n:
            continue
        (tx, ty, tz), (sx, sy, sz) = _world_of(nodes, i)
        min_y = min(min_y, ty - 0.5 * abs(sy))
        max_y = max(max_y, ty + 0.5 * abs(sy))
    height = max_y - min_y
    if min_y < -0.02 or min_y > 0.08:
        raise RuntimeError(f"Origin must sit at the feet (min Y={min_y:.3f})")
    if not (2.00 <= max_y <= 2.10):
        raise RuntimeError(f"Crown tip must be 2.00–2.10 m (max Y={max_y:.3f})")
    if not (2.00 <= height <= 2.10):
        raise RuntimeError(f"Blockout height {height:.3f} m is outside 2.00–2.10")
    return min_y, max_y


def build() -> bytes:
    positions, normals, indices = unit_cube()
    pos_b = pack_f32(positions)
    nrm_b = pack_f32(normals)
    idx_b = pack_u16(indices)
    blob = bytearray()
    views = []

    def add_view(data: bytes, target: int) -> int:
        align4(blob)
        offset = len(blob)
        blob.extend(data)
        views.append({"buffer": 0, "byteOffset": offset, "byteLength": len(data), "target": target})
        return len(views) - 1

    pos_view = add_view(pos_b, 34962)
    nrm_view = add_view(nrm_b, 34962)
    idx_view = add_view(idx_b, 34963)
    align4(blob)

    pos_min, pos_max = minmax(positions, 3)
    accessors = [
        {
            "bufferView": pos_view,
            "componentType": 5126,
            "count": len(positions) // 3,
            "type": "VEC3",
            "min": pos_min,
            "max": pos_max,
        },
        {
            "bufferView": nrm_view,
            "componentType": 5126,
            "count": len(normals) // 3,
            "type": "VEC3",
        },
        {
            "bufferView": idx_view,
            "componentType": 5123,
            "count": len(indices),
            "type": "SCALAR",
        },
    ]

    mat_names = list(MATERIALS)
    materials = []
    for key in mat_names:
        spec = MATERIALS[key]
        entry = {
            "name": key,
            "pbrMetallicRoughness": {
                "baseColorFactor": spec["color"],
                "metallicFactor": spec["metal"],
                "roughnessFactor": spec["rough"],
            },
        }
        if "emissive" in spec:
            entry["emissiveFactor"] = spec["emissive"]
        materials.append(entry)

    meshes = []
    mesh_of: dict[str, int] = {}
    for i, key in enumerate(mat_names):
        meshes.append(
            {
                "name": f"box_{key}",
                "primitives": [
                    {
                        "attributes": {"POSITION": 0, "NORMAL": 1},
                        "indices": 2,
                        "material": i,
                    }
                ],
            }
        )
        mesh_of[key] = i

    nodes: list[dict] = []

    def add(n: dict) -> int:
        nodes.append(n)
        return len(nodes) - 1

    def box(name: str, material: str, translation: tuple[float, float, float], size: tuple[float, float, float]) -> int:
        return add(node(name, translation=translation, scale=size, mesh=mesh_of[material]))

    def claws(prefix: str) -> list[int]:
        ## Mesh children of the fist — they ride the existing swipe/lunge poses.
        return [
            box(f"{prefix}_Claw1", "claw", (0.06, -0.15, -0.13), (0.035, 0.22, 0.055)),
            box(f"{prefix}_Claw2", "claw", (0.00, -0.18, -0.16), (0.040, 0.26, 0.060)),
            box(f"{prefix}_Claw3", "claw", (-0.06, -0.15, -0.13), (0.035, 0.22, 0.055)),
        ]

    # --- arms hang -Y; long gauntlets + claws so the 1.15s swipe chamber reads ---
    l_fist_mesh = box("L_FistMesh", "gauntlet", (0.0, -0.10, -0.06), (0.18, 0.18, 0.22))
    l_fist = add(node("L_Fist", translation=(0.0, -0.40, 0.0), children=[l_fist_mesh, *claws("L")]))
    l_fore_mesh = box("L_ForearmMesh", "gauntlet", (0.0, -0.18, -0.02), (0.15, 0.38, 0.16))
    l_fore = add(node("L_Forearm", translation=(0.0, -0.36, 0.0), children=[l_fore_mesh, l_fist]))
    l_up_mesh = box("L_UpperArmMesh", "coat", (0.0, -0.17, 0.0), (0.13, 0.36, 0.13))
    l_epaulette = box("L_Epaulette", "brass", (0.0, 0.02, 0.0), (0.18, 0.06, 0.15))
    l_up = add(node("L_UpperArm", translation=(-0.28, 0.40, 0.0), children=[l_up_mesh, l_epaulette, l_fore]))

    r_fist_mesh = box("R_FistMesh", "gauntlet", (0.0, -0.12, -0.08), (0.20, 0.20, 0.26))
    r_fist = add(node("R_Fist", translation=(0.0, -0.42, 0.0), children=[r_fist_mesh, *claws("R")]))
    r_fore_mesh = box("R_ForearmMesh", "gauntlet", (0.0, -0.20, -0.03), (0.16, 0.42, 0.17))
    r_fore = add(node("R_Forearm", translation=(0.0, -0.38, 0.0), children=[r_fore_mesh, r_fist]))
    r_up_mesh = box("R_UpperArmMesh", "coat", (0.0, -0.18, 0.0), (0.14, 0.38, 0.14))
    r_epaulette = box("R_Epaulette", "brass", (0.0, 0.02, 0.0), (0.18, 0.06, 0.15))
    r_up = add(node("R_UpperArm", translation=(0.28, 0.40, 0.0), children=[r_up_mesh, r_epaulette, r_fore]))

    horn_l = box("CrownHornL", "crown", (-0.11, 0.10, 0.04), (0.05, 0.18, 0.05))
    horn_c = box("CrownHornC", "crown", (0.0, 0.14, 0.0), (0.05, 0.20, 0.05))
    horn_r = box("CrownHornR", "crown", (0.11, 0.10, 0.04), (0.05, 0.18, 0.05))
    band = box("CrownBand", "crown", (0.0, 0.03, 0.0), (0.24, 0.05, 0.24))
    brim = box("TransitBrim", "brass", (0.0, 0.00, -0.07), (0.28, 0.03, 0.16))
    crown = add(node("Crown", translation=(0.0, 0.18, 0.0), children=[band, brim, horn_l, horn_c, horn_r]))

    visor = box("VoidVisor", "void", (0.0, 0.09, -0.10), (0.16, 0.055, 0.045))
    head_mesh = box("HeadMesh", "hollow", (0.0, 0.11, -0.02), (0.20, 0.22, 0.20))
    head = add(node("Head", translation=(0.0, 0.50, 0.0), children=[head_mesh, visor, crown]))

    mark = box("ChestMark", "mark", (0.0, 0.14, -0.14), (0.09, 0.20, 0.03))
    torso_mesh = box("TorsoMesh", "coat", (0.0, 0.22, 0.02), (0.48, 0.48, 0.28))
    collar = box("Collar", "coat", (0.0, 0.44, -0.02), (0.28, 0.10, 0.20))
    lapel_l = box("LapelL", "lining", (-0.07, 0.20, -0.13), (0.09, 0.32, 0.04))
    lapel_r = box("LapelR", "lining", (0.07, 0.20, -0.13), (0.09, 0.32, 0.04))
    btn_a = box("ButtonA", "brass", (-0.04, 0.24, -0.13), (0.035, 0.035, 0.03))
    btn_b = box("ButtonB", "brass", (0.04, 0.24, -0.13), (0.035, 0.035, 0.03))
    btn_c = box("ButtonC", "brass", (-0.04, 0.14, -0.13), (0.035, 0.035, 0.03))
    btn_d = box("ButtonD", "brass", (0.04, 0.14, -0.13), (0.035, 0.035, 0.03))
    torso = add(
        node(
            "Torso",
            translation=(0.0, 0.10, 0.0),
            children=[
                torso_mesh,
                collar,
                lapel_l,
                lapel_r,
                mark,
                btn_a,
                btn_b,
                btn_c,
                btn_d,
                head,
                l_up,
                r_up,
            ],
        )
    )

    l_foot = box("L_Foot", "boot", (0.0, -0.46, -0.07), (0.12, 0.08, 0.26))
    l_shin_mesh = box("L_ShinMesh", "pants", (0.0, -0.20, 0.0), (0.11, 0.40, 0.12))
    l_shin = add(node("L_Shin", translation=(0.0, -0.44, 0.0), children=[l_shin_mesh, l_foot]))
    l_thigh_mesh = box("L_ThighMesh", "pants", (0.0, -0.20, 0.0), (0.13, 0.40, 0.14))
    l_thigh = add(node("L_Thigh", translation=(-0.11, -0.06, 0.0), children=[l_thigh_mesh, l_shin]))

    r_foot = box("R_Foot", "boot", (0.0, -0.46, -0.07), (0.12, 0.08, 0.26))
    r_shin_mesh = box("R_ShinMesh", "pants", (0.0, -0.20, 0.0), (0.11, 0.40, 0.12))
    r_shin = add(node("R_Shin", translation=(0.0, -0.44, 0.0), children=[r_shin_mesh, r_foot]))
    r_thigh_mesh = box("R_ThighMesh", "pants", (0.0, -0.20, 0.0), (0.13, 0.40, 0.14))
    r_thigh = add(node("R_Thigh", translation=(0.11, -0.06, 0.0), children=[r_thigh_mesh, r_shin]))

    hips_mesh = box("HipsMesh", "pants", (0.0, 0.0, 0.0), (0.34, 0.14, 0.20))
    belt = box("Belt", "brass", (0.0, 0.07, 0.0), (0.38, 0.06, 0.22))
    ## Open transit coat: long back + side flaps; limbs stay readable for swipe/lunge.
    coat_back = box("CoatBack", "coat", (0.0, -0.46, 0.11), (0.48, 0.92, 0.12))
    coat_flare_l = box("CoatFlareL", "coat", (-0.26, -0.44, 0.02), (0.13, 0.86, 0.26))
    coat_flare_r = box("CoatFlareR", "coat", (0.26, -0.44, 0.02), (0.13, 0.86, 0.26))
    hem_lining = box("HemLining", "lining", (0.0, -0.88, 0.06), (0.44, 0.14, 0.08))
    hips = add(
        node(
            "Hips",
            translation=(0.0, 1.02, 0.0),
            children=[
                hips_mesh,
                belt,
                coat_back,
                coat_flare_l,
                coat_flare_r,
                hem_lining,
                torso,
                l_thigh,
                r_thigh,
            ],
        )
    )
    ## Same instance name as the temp so a path-only preload swap keeps MeshRoot/HeraldBlockout.
    root = add(node("HeraldBlockout", children=[hips]))

    min_y, max_y = verify_nodes(nodes)

    gltf = {
        "asset": {
            "version": "2.0",
            "generator": "line7/enemies/hollow_herald/build_hollow_herald_blockout.py",
        },
        "scene": 0,
        "scenes": [{"name": "HeraldBlockout", "nodes": [root]}],
        "nodes": nodes,
        "meshes": meshes,
        "materials": materials,
        "accessors": accessors,
        "bufferViews": views,
        "buffers": [{"byteLength": len(blob)}],
    }

    json_bytes = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    while len(json_bytes) % 4:
        json_bytes += b" "

    total = 12 + 8 + len(json_bytes) + 8 + len(blob)
    header = struct.pack("<4sII", b"glTF", 2, total)
    json_chunk = struct.pack("<I4s", len(json_bytes), b"JSON") + json_bytes
    bin_chunk = struct.pack("<I4s", len(blob), b"BIN\x00") + bytes(blob)
    packed = header + json_chunk + bin_chunk
    if len(packed) != total:
        raise RuntimeError(f"GLB size mismatch {len(packed)} != {total}")
    if packed[:4] != b"glTF":
        raise RuntimeError("GLB header missing")
    print(f"Verified rest AABB Y=[{min_y:.3f}, {max_y:.3f}] height={max_y - min_y:.3f}m")
    return packed


def main() -> None:
    data = build()
    OUT.write_bytes(data)
    print(f"Wrote {OUT} ({len(data)} bytes, official ~2.05m lesser-demon blockout)")


if __name__ == "__main__":
    main()
