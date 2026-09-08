#!/usr/bin/env python3
"""Rebuild enemies/hollow_herald/herald_blockout.glb — ~2.35m transit-coat humanoid.

Long coat + oversized swipe arms so the fist-punish wind-up reads at a glance.
Hierarchy is joint nodes (no scale) with mesh children (scale = box size) so
Herald can pose parts without squash. Origin at the feet, Y-up, +Z glTF
forward (Godot imports that as -Z).

Usage:
    python3 enemies/hollow_herald/build_herald_blockout.py
"""

from __future__ import annotations

import json
import struct
from pathlib import Path

OUT = Path(__file__).with_name("herald_blockout.glb")


MATERIALS = {
    ## Mid values so the coat reads in the dim undercroft, not a grey capsule.
    "coat": {"color": [0.58, 0.60, 0.70, 1.0], "rough": 0.70, "metal": 0.06},
    "lining": {
        "color": [0.52, 0.22, 0.26, 1.0],
        "rough": 0.58,
        "metal": 0.0,
        "emissive": [0.18, 0.04, 0.05],
    },
    "pants": {"color": [0.28, 0.28, 0.34, 1.0], "rough": 0.84, "metal": 0.0},
    "hollow": {"color": [0.78, 0.72, 0.66, 1.0], "rough": 0.58, "metal": 0.0},
    "gauntlet": {
        "color": [0.52, 0.40, 0.42, 1.0],
        "rough": 0.44,
        "metal": 0.14,
        "emissive": [0.18, 0.06, 0.07],
    },
    "crown": {
        "color": [0.82, 0.76, 0.50, 1.0],
        "rough": 0.32,
        "metal": 0.48,
        "emissive": [0.38, 0.30, 0.10],
    },
    "brass": {
        "color": [0.72, 0.60, 0.36, 1.0],
        "rough": 0.40,
        "metal": 0.42,
        "emissive": [0.10, 0.07, 0.02],
    },
    "void": {
        "color": [0.08, 0.07, 0.09, 1.0],
        "rough": 0.22,
        "metal": 0.18,
        "emissive": [0.18, 0.12, 0.06],
    },
    "boot": {"color": [0.14, 0.13, 0.12, 1.0], "rough": 0.52, "metal": 0.10},
    "mark": {
        "color": [0.58, 0.20, 0.22, 1.0],
        "rough": 0.40,
        "metal": 0.0,
        "emissive": [0.32, 0.06, 0.05],
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

    # --- arms hang -Y; extra-long gauntlets so swipe wind-up is loud ---
    l_fist_mesh = box("L_FistMesh", "gauntlet", (0.0, -0.12, -0.06), (0.20, 0.20, 0.24))
    l_fist = add(node("L_Fist", translation=(0.0, -0.42, 0.0), children=[l_fist_mesh]))
    l_fore_mesh = box("L_ForearmMesh", "gauntlet", (0.0, -0.20, -0.02), (0.16, 0.42, 0.17))
    l_fore = add(node("L_Forearm", translation=(0.0, -0.38, 0.0), children=[l_fore_mesh, l_fist]))
    l_up_mesh = box("L_UpperArmMesh", "coat", (0.0, -0.18, 0.0), (0.13, 0.38, 0.13))
    l_epaulette = box("L_Epaulette", "brass", (0.0, 0.02, 0.0), (0.20, 0.07, 0.16))
    l_up = add(node("L_UpperArm", translation=(-0.30, 0.44, 0.0), children=[l_up_mesh, l_epaulette, l_fore]))

    r_fist_mesh = box("R_FistMesh", "gauntlet", (0.0, -0.14, -0.08), (0.22, 0.22, 0.28))
    r_fist = add(node("R_Fist", translation=(0.0, -0.46, 0.0), children=[r_fist_mesh]))
    r_fore_mesh = box("R_ForearmMesh", "gauntlet", (0.0, -0.22, -0.03), (0.17, 0.46, 0.18))
    r_fore = add(node("R_Forearm", translation=(0.0, -0.40, 0.0), children=[r_fore_mesh, r_fist]))
    r_up_mesh = box("R_UpperArmMesh", "coat", (0.0, -0.20, 0.0), (0.14, 0.42, 0.14))
    r_epaulette = box("R_Epaulette", "brass", (0.0, 0.02, 0.0), (0.20, 0.07, 0.16))
    r_up = add(node("R_UpperArm", translation=(0.30, 0.44, 0.0), children=[r_up_mesh, r_epaulette, r_fore]))

    spike_l = box("CrownSpikeL", "crown", (-0.10, 0.12, 0.0), (0.05, 0.16, 0.05))
    spike_c = box("CrownSpikeC", "crown", (0.0, 0.16, 0.0), (0.05, 0.22, 0.05))
    spike_r = box("CrownSpikeR", "crown", (0.10, 0.12, 0.0), (0.05, 0.16, 0.05))
    band = box("CrownBand", "crown", (0.0, 0.04, 0.0), (0.26, 0.06, 0.26))
    brim = box("TransitBrim", "brass", (0.0, 0.00, -0.08), (0.30, 0.03, 0.18))
    crown = add(node("Crown", translation=(0.0, 0.20, 0.0), children=[band, brim, spike_l, spike_c, spike_r]))

    visor = box("VoidVisor", "void", (0.0, 0.10, -0.11), (0.18, 0.06, 0.05))
    head_mesh = box("HeadMesh", "hollow", (0.0, 0.12, -0.02), (0.22, 0.24, 0.22))
    head = add(node("Head", translation=(0.0, 0.58, 0.0), children=[head_mesh, visor, crown]))

    mark = box("ChestMark", "mark", (0.0, 0.16, -0.15), (0.10, 0.22, 0.03))
    torso_mesh = box("TorsoMesh", "coat", (0.0, 0.24, 0.02), (0.50, 0.54, 0.28))
    collar = box("Collar", "coat", (0.0, 0.50, -0.02), (0.30, 0.12, 0.22))
    lapel_l = box("LapelL", "lining", (-0.08, 0.22, -0.14), (0.10, 0.36, 0.04))
    lapel_r = box("LapelR", "lining", (0.08, 0.22, -0.14), (0.10, 0.36, 0.04))
    btn_a = box("ButtonA", "brass", (-0.05, 0.28, -0.14), (0.04, 0.04, 0.03))
    btn_b = box("ButtonB", "brass", (0.05, 0.28, -0.14), (0.04, 0.04, 0.03))
    btn_c = box("ButtonC", "brass", (-0.05, 0.16, -0.14), (0.04, 0.04, 0.03))
    btn_d = box("ButtonD", "brass", (0.05, 0.16, -0.14), (0.04, 0.04, 0.03))
    torso = add(
        node(
            "Torso",
            translation=(0.0, 0.12, 0.0),
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

    l_foot = box("L_Foot", "boot", (0.0, -0.05, -0.08), (0.13, 0.09, 0.28))
    l_shin_mesh = box("L_ShinMesh", "pants", (0.0, -0.24, 0.0), (0.12, 0.48, 0.13))
    l_shin = add(node("L_Shin", translation=(0.0, -0.50, 0.0), children=[l_shin_mesh, l_foot]))
    l_thigh_mesh = box("L_ThighMesh", "pants", (0.0, -0.24, 0.0), (0.14, 0.48, 0.15))
    l_thigh = add(node("L_Thigh", translation=(-0.12, -0.08, 0.0), children=[l_thigh_mesh, l_shin]))

    r_foot = box("R_Foot", "boot", (0.0, -0.05, -0.08), (0.13, 0.09, 0.28))
    r_shin_mesh = box("R_ShinMesh", "pants", (0.0, -0.24, 0.0), (0.12, 0.48, 0.13))
    r_shin = add(node("R_Shin", translation=(0.0, -0.50, 0.0), children=[r_shin_mesh, r_foot]))
    r_thigh_mesh = box("R_ThighMesh", "pants", (0.0, -0.24, 0.0), (0.14, 0.48, 0.15))
    r_thigh = add(node("R_Thigh", translation=(0.12, -0.08, 0.0), children=[r_thigh_mesh, r_shin]))

    hips_mesh = box("HipsMesh", "pants", (0.0, 0.0, 0.0), (0.36, 0.16, 0.22))
    belt = box("Belt", "brass", (0.0, 0.08, 0.0), (0.40, 0.07, 0.24))
    ## Open transit coat: long back + side flaps so swipe/lunge limbs stay readable.
    coat_back = box("CoatBack", "coat", (0.0, -0.54, 0.12), (0.50, 1.10, 0.12))
    coat_flare_l = box("CoatFlareL", "coat", (-0.28, -0.52, 0.02), (0.14, 1.02, 0.28))
    coat_flare_r = box("CoatFlareR", "coat", (0.28, -0.52, 0.02), (0.14, 1.02, 0.28))
    hem_lining = box("HemLining", "lining", (0.0, -1.02, 0.06), (0.46, 0.16, 0.08))
    hips = add(
        node(
            "Hips",
            translation=(0.0, 1.18, 0.0),
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
    root = add(node("HeraldBlockout", children=[hips]))

    gltf = {
        "asset": {
            "version": "2.0",
            "generator": "line7/enemies/hollow_herald/build_herald_blockout.py",
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
    return packed


def main() -> None:
    data = build()
    OUT.write_bytes(data)
    print(f"Wrote {OUT} ({len(data)} bytes, ~{2.35:.2f}m transit-coat blockout)")


if __name__ == "__main__":
    main()
