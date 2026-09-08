#!/usr/bin/env python3
"""Rebuild characters/he/he_blockout.glb — ~1.8m civilian box humanoid.

Oversized fists/forearms so jab and heavy read at a glance. Hierarchy is
joint nodes (no scale) with mesh children (scale = box size) so HE can
pose parts without squash. Origin at the feet, Y-up, +Z glTF forward
(Godot imports that as -Z).

Usage:
    python3 characters/he/build_he_blockout.py
"""

from __future__ import annotations

import json
import struct
from pathlib import Path

OUT = Path(__file__).with_name("he_blockout.glb")


def srgb(r: int, g: int, b: int) -> list[float]:
    return [round((c / 255.0) ** 2.2, 6) for c in (r, g, b)] + [1.0]


MATERIALS = {
    "coat": {"color": srgb(74, 69, 60), "rough": 0.82, "metal": 0.0},
    "shirt": {"color": srgb(52, 68, 66), "rough": 0.78, "metal": 0.0},
    "pants": {"color": srgb(38, 40, 46), "rough": 0.86, "metal": 0.0},
    "skin": {"color": srgb(196, 160, 122), "rough": 0.62, "metal": 0.0},
    "hair": {"color": srgb(26, 24, 22), "rough": 0.9, "metal": 0.0},
    "wrap": {"color": srgb(139, 64, 48), "rough": 0.7, "metal": 0.05},
    "boot": {"color": srgb(28, 26, 24), "rough": 0.55, "metal": 0.08},
    "visor": {
        "color": srgb(28, 48, 58),
        "rough": 0.22,
        "metal": 0.35,
        "emissive": [0.08, 0.28, 0.32],
    },
    "belt": {"color": srgb(61, 46, 34), "rough": 0.7, "metal": 0.04},
    "mark": {
        "color": srgb(180, 48, 42),
        "rough": 0.45,
        "metal": 0.0,
        "emissive": [0.22, 0.04, 0.03],
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

    # Built leaves-first so child indices exist when parents are appended.
    nodes: list[dict] = []

    def add(n: dict) -> int:
        nodes.append(n)
        return len(nodes) - 1

    def box(name: str, material: str, translation: tuple[float, float, float], size: tuple[float, float, float]) -> int:
        return add(node(name, translation=translation, scale=size, mesh=mesh_of[material]))

    # --- left arm (hangs -Y; oversized forearm + fist) ---
    l_fist_mesh = box("L_FistMesh", "wrap", (0.0, -0.10, 0.05), (0.17, 0.16, 0.20))
    l_fist = add(node("L_Fist", translation=(0.0, -0.34, 0.0), children=[l_fist_mesh]))
    l_fore_mesh = box("L_ForearmMesh", "wrap", (0.0, -0.16, 0.02), (0.13, 0.32, 0.14))
    l_fore = add(node("L_Forearm", translation=(0.0, -0.30, 0.0), children=[l_fore_mesh, l_fist]))
    l_up_mesh = box("L_UpperArmMesh", "coat", (0.0, -0.14, 0.0), (0.09, 0.28, 0.09))
    l_up = add(node("L_UpperArm", translation=(-0.22, 0.38, 0.0), children=[l_up_mesh, l_fore]))

    r_fist_mesh = box("R_FistMesh", "wrap", (0.0, -0.10, 0.05), (0.17, 0.16, 0.20))
    r_fist = add(node("R_Fist", translation=(0.0, -0.34, 0.0), children=[r_fist_mesh]))
    r_fore_mesh = box("R_ForearmMesh", "wrap", (0.0, -0.16, 0.02), (0.13, 0.32, 0.14))
    r_fore = add(node("R_Forearm", translation=(0.0, -0.30, 0.0), children=[r_fore_mesh, r_fist]))
    r_up_mesh = box("R_UpperArmMesh", "coat", (0.0, -0.14, 0.0), (0.09, 0.28, 0.09))
    r_up = add(node("R_UpperArm", translation=(0.22, 0.38, 0.0), children=[r_up_mesh, r_fore]))

    visor = box("Visor", "visor", (0.0, 0.11, 0.10), (0.16, 0.045, 0.04))
    hair = box("Hair", "hair", (0.0, 0.18, -0.02), (0.22, 0.10, 0.22))
    head_mesh = box("HeadMesh", "skin", (0.0, 0.11, 0.02), (0.20, 0.22, 0.20))
    head = add(node("Head", translation=(0.0, 0.50, 0.0), children=[head_mesh, hair, visor]))

    chest = box("ChestMark", "mark", (0.08, 0.16, 0.12), (0.07, 0.20, 0.03))
    torso_mesh = box("TorsoMesh", "coat", (0.0, 0.22, 0.0), (0.38, 0.46, 0.22))
    shirt = box("ShirtFront", "shirt", (0.0, 0.14, 0.11), (0.22, 0.28, 0.04))
    torso = add(
        node(
            "Torso",
            translation=(0.0, 0.10, 0.0),
            children=[torso_mesh, shirt, chest, head, l_up, r_up],
        )
    )

    l_foot = box("L_Foot", "boot", (0.0, -0.04, 0.07), (0.11, 0.08, 0.24))
    l_shin_mesh = box("L_ShinMesh", "pants", (0.0, -0.20, 0.0), (0.10, 0.40, 0.11))
    l_shin = add(node("L_Shin", translation=(0.0, -0.42, 0.0), children=[l_shin_mesh, l_foot]))
    l_thigh_mesh = box("L_ThighMesh", "pants", (0.0, -0.20, 0.0), (0.12, 0.40, 0.13))
    l_thigh = add(node("L_Thigh", translation=(-0.10, -0.06, 0.0), children=[l_thigh_mesh, l_shin]))

    r_foot = box("R_Foot", "boot", (0.0, -0.04, 0.07), (0.11, 0.08, 0.24))
    r_shin_mesh = box("R_ShinMesh", "pants", (0.0, -0.20, 0.0), (0.10, 0.40, 0.11))
    r_shin = add(node("R_Shin", translation=(0.0, -0.42, 0.0), children=[r_shin_mesh, r_foot]))
    r_thigh_mesh = box("R_ThighMesh", "pants", (0.0, -0.20, 0.0), (0.12, 0.40, 0.13))
    r_thigh = add(node("R_Thigh", translation=(0.10, -0.06, 0.0), children=[r_thigh_mesh, r_shin]))

    hips_mesh = box("HipsMesh", "pants", (0.0, 0.0, 0.0), (0.30, 0.14, 0.18))
    belt = box("Belt", "belt", (0.0, 0.06, 0.0), (0.34, 0.06, 0.20))
    hips = add(
        node(
            "Hips",
            translation=(0.0, 0.92, 0.0),
            children=[hips_mesh, belt, torso, l_thigh, r_thigh],
        )
    )
    root = add(node("HEBlockout", children=[hips]))

    gltf = {
        "asset": {
            "version": "2.0",
            "generator": "line7/characters/he/build_he_blockout.py",
        },
        "scene": 0,
        "scenes": [{"name": "HEBlockout", "nodes": [root]}],
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
    print(f"Wrote {OUT} ({len(data)} bytes, ~{1.80:.2f}m civilian blockout)")


if __name__ == "__main__":
    main()
