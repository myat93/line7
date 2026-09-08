#!/usr/bin/env python3
"""Shared glTF 2.0 helpers for Line 7 character meshes.

Builds capsule / sphere / tapered-cylinder geometry with UVs so the HE and
Herald visuals read as posed 3D humans instead of unit-cube blockouts.
"""

from __future__ import annotations

import json
import math
import struct
import zlib
from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable

TAU = math.tau


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


def png_rgb(width: int, height: int, pixels: list[tuple[int, int, int]]) -> bytes:
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        row = y * width
        for x in range(width):
            r, g, b = pixels[row + x]
            raw.extend((r, g, b))

    def chunk(tag: bytes, data: bytes) -> bytes:
        crc = zlib.crc32(tag + data) & 0xFFFFFFFF
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", crc)

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", ihdr) + chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")


def _noise(x: int, y: int, seed: int) -> float:
    n = (x * 374761393 + y * 668265263 + seed * 1274126177) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177
    return ((n ^ (n >> 16)) & 0xFFFFFFFF) / 4294967295.0


def make_texture(kind: str, size: int = 128) -> bytes:
    px: list[tuple[int, int, int]] = []
    for y in range(size):
        for x in range(size):
            n = _noise(x, y, 11)
            n2 = _noise(x // 3, y // 2, 29)
            u = x / size
            v = y / size
            if kind == "skin":
                mott = 0.72 + 0.04 * math.sin(u * 6.0) * math.sin(v * 5.0) + n * 0.03
                r, g, b = mott * 0.84, mott * 0.62, mott * 0.50
            elif kind == "hollow":
                mott = 0.58 + 0.04 * n + 0.02 * math.sin(v * 8.0)
                r, g, b = mott * 0.90, mott * 0.80, mott * 0.72
            elif kind == "coat":
                weave = 0.30 + 0.03 * math.sin(u * 18.0) + 0.02 * math.sin(v * 10.0) + n * 0.03
                r, g, b = weave * 0.78, weave * 0.68, weave * 0.56
            elif kind == "herald_coat":
                weave = 0.22 + 0.03 * math.sin(u * 14.0) + 0.03 * n
                r, g, b = weave * 0.92, weave * 0.88, weave * 1.05
            elif kind == "shirt":
                t = 0.22 + 0.03 * math.sin(u * 10.0) + n * 0.03
                r, g, b = t * 0.62, t * 0.70, t * 0.66
            elif kind == "pants":
                denim = 0.16 + 0.03 * math.sin(u * 12.0) + 0.03 * n2
                r, g, b = denim * 0.62, denim * 0.64, denim * 0.72
            elif kind == "hair":
                t = 0.08 + 0.03 * abs(math.sin(u * 16.0 + v * 4.0)) + n * 0.02
                r, g, b = t * 1.05, t * 0.82, t * 0.68
            elif kind == "wrap":
                t = 0.28 + 0.05 * math.sin((u + v) * 10.0) + n * 0.03
                r, g, b = t * 1.05, t * 0.58, t * 0.40
            elif kind == "boot":
                t = 0.12 + 0.05 * n + 0.03 * math.sin(v * 22.0)
                r, g, b = t * 1.15, t * 0.9, t * 0.72
            elif kind == "leather":
                t = 0.28 + 0.10 * math.sin(u * 16.0 + v * 6.0) + n * 0.07
                r, g, b = t * 1.25, t * 0.62, t * 0.34
            elif kind == "lining":
                t = 0.34 + 0.10 * math.sin(u * 22.0) + n * 0.05
                r, g, b = t * 1.35, t * 0.38, t * 0.36
            elif kind == "belt":
                t = 0.22 + 0.06 * n
                r, g, b = t * 1.2, t * 0.78, t * 0.48
            elif kind == "brass":
                t = 0.55 + 0.18 * n2
                r, g, b = t * 1.15, t * 0.88, t * 0.42
            elif kind == "gauntlet":
                t = 0.30 + 0.08 * n
                r, g, b = t * 1.15, t * 0.72, t * 0.70
            elif kind == "crown":
                t = 0.58 + 0.16 * n2
                r, g, b = t * 1.2, t * 1.0, t * 0.48
            elif kind == "void":
                t = 0.04 + 0.03 * n
                r, g, b = t * 1.2, t * 0.7, t * 0.55
            elif kind == "eye":
                r, g, b = 0.92, 0.90, 0.86
            elif kind == "iris":
                r, g, b = 0.18, 0.28, 0.30
            elif kind == "mark":
                t = 0.55 + 0.15 * n
                r, g, b = t * 1.2, t * 0.28, t * 0.22
            else:
                r, g, b = 0.5, 0.5, 0.5
            px.append((int(max(0, min(255, r * 255))), int(max(0, min(255, g * 255))), int(max(0, min(255, b * 255)))))
    return png_rgb(size, size, px)


@dataclass
class Mesh:
    name: str
    positions: list[float] = field(default_factory=list)
    normals: list[float] = field(default_factory=list)
    uvs: list[float] = field(default_factory=list)
    indices: list[int] = field(default_factory=list)

    def add_tri(self, a: int, b: int, c: int) -> None:
        self.indices.extend((a, b, c))

    def add_vert(self, p: tuple[float, float, float], n: tuple[float, float, float], uv: tuple[float, float]) -> int:
        idx = len(self.positions) // 3
        self.positions.extend(p)
        self.normals.extend(n)
        self.uvs.extend(uv)
        return idx

    def bounds(self) -> tuple[list[float], list[float]]:
        return minmax(self.positions, 3)


def _norm(x: float, y: float, z: float) -> tuple[float, float, float]:
    length = math.sqrt(x * x + y * y + z * z)
    if length < 1e-8:
        return (0.0, 1.0, 0.0)
    return (x / length, y / length, z / length)


def sphere(name: str, radius: float, segs: int = 14, rings: int = 10) -> Mesh:
    mesh = Mesh(name)
    for ring in range(rings + 1):
        v = ring / rings
        phi = v * math.pi
        sy = math.cos(phi)
        sr = math.sin(phi)
        for seg in range(segs + 1):
            u = seg / segs
            th = u * TAU
            x = math.cos(th) * sr
            z = math.sin(th) * sr
            n = _norm(x, sy, z)
            mesh.add_vert((x * radius, sy * radius, z * radius), n, (u, v))
    cols = segs + 1
    for ring in range(rings):
        for seg in range(segs):
            a = ring * cols + seg
            b = a + cols
            mesh.add_tri(a, b, a + 1)
            mesh.add_tri(a + 1, b, b + 1)
    return mesh


def ellipsoid(name: str, rx: float, ry: float, rz: float, segs: int = 14, rings: int = 10) -> Mesh:
    mesh = sphere(name, 1.0, segs, rings)
    for i in range(0, len(mesh.positions), 3):
        mesh.positions[i] *= rx
        mesh.positions[i + 1] *= ry
        mesh.positions[i + 2] *= rz
        nx, ny, nz = mesh.normals[i], mesh.normals[i + 1], mesh.normals[i + 2]
        mesh.normals[i], mesh.normals[i + 1], mesh.normals[i + 2] = _norm(nx / max(rx, 1e-5), ny / max(ry, 1e-5), nz / max(rz, 1e-5))
    return mesh


def capsule(name: str, radius: float, height: float, segs: int = 14, rings: int = 5) -> Mesh:
    """Y-up capsule. `height` is total including hemispheres."""
    mesh = Mesh(name)
    cyl = max(height - 2.0 * radius, 0.02)
    half = cyl * 0.5
    # bottom hemisphere, mid cylinder, top hemisphere
    rows: list[tuple[float, float, float]] = []  # y, ring_radius, v
    for ring in range(rings + 1):
        t = ring / rings
        phi = math.pi * 0.5 + t * math.pi * 0.5
        rows.append((-half + math.cos(phi) * radius, math.sin(phi) * radius, t * 0.25))
    for ring in range(1, rings):
        t = ring / rings
        rows.append((-half + t * cyl, radius, 0.25 + t * 0.5))
    for ring in range(rings + 1):
        t = ring / rings
        phi = t * math.pi * 0.5
        rows.append((half + math.sin(phi) * radius, math.cos(phi) * radius, 0.75 + t * 0.25))
    cols = segs + 1
    for y, rr, v in rows:
        for seg in range(cols):
            u = seg / segs
            th = u * TAU
            x = math.cos(th) * rr
            z = math.sin(th) * rr
            if abs(y) <= half + 1e-4 and abs(rr - radius) < 1e-4:
                n = _norm(x, 0.0, z)
            else:
                n = _norm(x, y - (half if y > 0 else -half), z)
            mesh.add_vert((x, y, z), n, (u, v))
    for row in range(len(rows) - 1):
        for seg in range(segs):
            a = row * cols + seg
            b = a + cols
            mesh.add_tri(a, b, a + 1)
            mesh.add_tri(a + 1, b, b + 1)
    return mesh


def cylinder(name: str, r_top: float, r_bot: float, height: float, segs: int = 14, caps: bool = True) -> Mesh:
    mesh = Mesh(name)
    half = height * 0.5
    cols = segs + 1
    for row, (y, r, v) in enumerate(((-half, r_bot, 0.0), (half, r_top, 1.0))):
        for seg in range(cols):
            u = seg / segs
            th = u * TAU
            x = math.cos(th) * r
            z = math.sin(th) * r
            n = _norm(x, (r_bot - r_top) * 0.35, z)
            mesh.add_vert((x, y, z), n, (u, v))
    for seg in range(segs):
        a = seg
        b = a + cols
        mesh.add_tri(a, b, a + 1)
        mesh.add_tri(a + 1, b, b + 1)
    if caps:
        for y, r, ny, v in ((-half, r_bot, -1.0, 0.0), (half, r_top, 1.0, 1.0)):
            center = mesh.add_vert((0.0, y, 0.0), (0.0, ny, 0.0), (0.5, v))
            ring: list[int] = []
            for seg in range(segs):
                u = seg / segs
                th = u * TAU
                ring.append(mesh.add_vert((math.cos(th) * r, y, math.sin(th) * r), (0.0, ny, 0.0), (0.5 + 0.5 * math.cos(th), 0.5 + 0.5 * math.sin(th))))
            for i in range(segs):
                a = ring[i]
                b = ring[(i + 1) % segs]
                if ny > 0:
                    mesh.add_tri(center, a, b)
                else:
                    mesh.add_tri(center, b, a)
    return mesh


def box(name: str, size: tuple[float, float, float]) -> Mesh:
    sx, sy, sz = size
    hx, hy, hz = sx * 0.5, sy * 0.5, sz * 0.5
    faces = [
        ((hx, -hy, -hz), (hx, hy, -hz), (hx, hy, hz), (hx, -hy, hz), (1, 0, 0)),
        ((-hx, -hy, hz), (-hx, hy, hz), (-hx, hy, -hz), (-hx, -hy, -hz), (-1, 0, 0)),
        ((-hx, hy, -hz), (-hx, hy, hz), (hx, hy, hz), (hx, hy, -hz), (0, 1, 0)),
        ((-hx, -hy, hz), (-hx, -hy, -hz), (hx, -hy, -hz), (hx, -hy, hz), (0, -1, 0)),
        ((-hx, -hy, hz), (hx, -hy, hz), (hx, hy, hz), (-hx, hy, hz), (0, 0, 1)),
        ((hx, -hy, -hz), (-hx, -hy, -hz), (-hx, hy, -hz), (hx, hy, -hz), (0, 0, -1)),
    ]
    mesh = Mesh(name)
    for a, b, c, d, n in faces:
        uvs = ((0.0, 1.0), (0.0, 0.0), (1.0, 0.0), (1.0, 1.0))
        base = len(mesh.positions) // 3
        for p, uv in zip((a, b, c, d), uvs):
            mesh.add_vert(p, n, uv)
        mesh.add_tri(base, base + 1, base + 2)
        mesh.add_tri(base, base + 2, base + 3)
    return mesh


def plane(name: str, width: float, height: float, subdiv: int = 3) -> Mesh:
    mesh = Mesh(name)
    for iy in range(subdiv + 1):
        v = iy / subdiv
        y = (0.5 - v) * height
        sag = (1.0 - math.cos((v - 0.5) * math.pi)) * 0.04 * height
        for ix in range(subdiv + 1):
            u = ix / subdiv
            x = (u - 0.5) * width
            mesh.add_vert((x, y - sag * 0.15, sag), (0.0, 0.15, 1.0), (u, v))
    cols = subdiv + 1
    for iy in range(subdiv):
        for ix in range(subdiv):
            a = iy * cols + ix
            b = a + cols
            mesh.add_tri(a, b, a + 1)
            mesh.add_tri(a + 1, b, b + 1)
            mesh.add_tri(a, a + 1, b)
            mesh.add_tri(a + 1, b + 1, b)
    return mesh


def translate_mesh(mesh: Mesh, offset: tuple[float, float, float]) -> Mesh:
    ox, oy, oz = offset
    out = Mesh(mesh.name, mesh.positions[:], mesh.normals[:], mesh.uvs[:], mesh.indices[:])
    for i in range(0, len(out.positions), 3):
        out.positions[i] += ox
        out.positions[i + 1] += oy
        out.positions[i + 2] += oz
    return out


def rotate_mesh_x(mesh: Mesh, radians: float) -> Mesh:
    c, s = math.cos(radians), math.sin(radians)
    out = Mesh(mesh.name, mesh.positions[:], mesh.normals[:], mesh.uvs[:], mesh.indices[:])
    for i in range(0, len(out.positions), 3):
        y, z = out.positions[i + 1], out.positions[i + 2]
        out.positions[i + 1] = y * c - z * s
        out.positions[i + 2] = y * s + z * c
        ny, nz = out.normals[i + 1], out.normals[i + 2]
        out.normals[i + 1] = ny * c - nz * s
        out.normals[i + 2] = ny * s + nz * c
    return out


def rotate_mesh_z(mesh: Mesh, radians: float) -> Mesh:
    c, s = math.cos(radians), math.sin(radians)
    out = Mesh(mesh.name, mesh.positions[:], mesh.normals[:], mesh.uvs[:], mesh.indices[:])
    for i in range(0, len(out.positions), 3):
        x, y = out.positions[i], out.positions[i + 1]
        out.positions[i] = x * c - y * s
        out.positions[i + 1] = x * s + y * c
        nx, ny = out.normals[i], out.normals[i + 1]
        out.normals[i] = nx * c - ny * s
        out.normals[i + 1] = nx * s + ny * c
    return out


class GlbBuilder:
    def __init__(self, generator: str) -> None:
        self.generator = generator
        self.materials: list[dict] = []
        self.mat_index: dict[str, int] = {}
        self.images: list[bytes] = []
        self.image_index: dict[str, int] = {}
        self.meshes: list[tuple[str, Mesh, int]] = []
        self.mesh_index: dict[str, int] = {}
        self.nodes: list[dict] = []

    def add_material(
        self,
        name: str,
        color: list[float],
        rough: float,
        metal: float = 0.0,
        emissive: list[float] | None = None,
        texture: str | None = None,
        double_sided: bool = False,
    ) -> int:
        if name in self.mat_index:
            return self.mat_index[name]
        entry: dict = {
            "name": name,
            "pbrMetallicRoughness": {
                "baseColorFactor": color,
                "metallicFactor": metal,
                "roughnessFactor": rough,
            },
        }
        if texture:
            if texture not in self.image_index:
                self.image_index[texture] = len(self.images)
                self.images.append(make_texture(texture))
            img = self.image_index[texture]
            entry["pbrMetallicRoughness"]["baseColorTexture"] = {"index": img}
        if emissive:
            entry["emissiveFactor"] = emissive
        if double_sided:
            entry["doubleSided"] = True
        self.mat_index[name] = len(self.materials)
        self.materials.append(entry)
        return self.mat_index[name]

    def add_mesh(self, mesh: Mesh, material: str) -> int:
        key = f"{mesh.name}:{material}"
        if key in self.mesh_index:
            return self.mesh_index[key]
        self.mesh_index[key] = len(self.meshes)
        self.meshes.append((mesh.name, mesh, self.mat_index[material]))
        return self.mesh_index[key]

    def add_node(
        self,
        name: str,
        translation: tuple[float, float, float] | None = None,
        children: list[int] | None = None,
        mesh: int | None = None,
        scale: tuple[float, float, float] | None = None,
    ) -> int:
        node: dict = {"name": name}
        if translation is not None:
            node["translation"] = [round(v, 5) for v in translation]
        if scale is not None:
            node["scale"] = [round(v, 5) for v in scale]
        if mesh is not None:
            node["mesh"] = mesh
        if children:
            node["children"] = children
        self.nodes.append(node)
        return len(self.nodes) - 1

    def mesh_node(
        self,
        name: str,
        mesh: Mesh,
        material: str,
        translation: tuple[float, float, float] = (0.0, 0.0, 0.0),
    ) -> int:
        return self.add_node(name, translation=translation, mesh=self.add_mesh(mesh, material))

    def world_of(self, idx: int) -> tuple[tuple[float, float, float], tuple[float, float, float]]:
        parent_of: dict[int, int] = {}
        for i, n in enumerate(self.nodes):
            for child in n.get("children", []):
                parent_of[child] = i
        chain = []
        cur = idx
        while True:
            chain.append(cur)
            if cur not in parent_of:
                break
            cur = parent_of[cur]
        tx = ty = tz = 0.0
        sx = sy = sz = 1.0
        for i in reversed(chain):
            n = self.nodes[i]
            t = n.get("translation", [0.0, 0.0, 0.0])
            s = n.get("scale", [1.0, 1.0, 1.0])
            tx += t[0] * sx
            ty += t[1] * sy
            tz += t[2] * sz
            sx *= s[0]
            sy *= s[1]
            sz *= s[2]
        return (tx, ty, tz), (sx, sy, sz)

    def mesh_world_aabb(self) -> tuple[float, float]:
        min_y, max_y = 1e9, -1e9
        for i, n in enumerate(self.nodes):
            if "mesh" not in n:
                continue
            (tx, ty, tz), (sx, sy, sz) = self.world_of(i)
            mesh = self.meshes[n["mesh"]][1]
            lo, hi = mesh.bounds()
            min_y = min(min_y, ty + lo[1] * sy)
            max_y = max(max_y, ty + hi[1] * sy)
        return min_y, max_y

    def pack(self, scene_name: str, root: int) -> bytes:
        blob = bytearray()
        views: list[dict] = []
        accessors: list[dict] = []
        images = []
        textures = []
        samplers = [{"magFilter": 9729, "minFilter": 9987, "wrapS": 10497, "wrapT": 10497}]

        def add_view(data: bytes, target: int | None = None) -> int:
            align4(blob)
            offset = len(blob)
            blob.extend(data)
            view: dict = {"buffer": 0, "byteOffset": offset, "byteLength": len(data)}
            if target is not None:
                view["target"] = target
            views.append(view)
            return len(views) - 1

        for png in self.images:
            view = add_view(png)
            images.append({"mimeType": "image/png", "bufferView": view})
            textures.append({"sampler": 0, "source": len(images) - 1})

        materials = []
        for mat in self.materials:
            entry = json.loads(json.dumps(mat))
            pbr = entry["pbrMetallicRoughness"]
            if "baseColorTexture" in pbr:
                pbr["baseColorTexture"] = {"index": pbr["baseColorTexture"]["index"]}
            materials.append(entry)

        gltf_meshes = []
        for name, mesh, mat_i in self.meshes:
            pos_view = add_view(pack_f32(mesh.positions), 34962)
            nrm_view = add_view(pack_f32(mesh.normals), 34962)
            uv_view = add_view(pack_f32(mesh.uvs), 34962)
            idx_view = add_view(pack_u16(mesh.indices), 34963)
            pos_min, pos_max = mesh.bounds()
            ap = len(accessors)
            accessors.append(
                {
                    "bufferView": pos_view,
                    "componentType": 5126,
                    "count": len(mesh.positions) // 3,
                    "type": "VEC3",
                    "min": pos_min,
                    "max": pos_max,
                }
            )
            accessors.append(
                {
                    "bufferView": nrm_view,
                    "componentType": 5126,
                    "count": len(mesh.normals) // 3,
                    "type": "VEC3",
                }
            )
            accessors.append(
                {
                    "bufferView": uv_view,
                    "componentType": 5126,
                    "count": len(mesh.uvs) // 2,
                    "type": "VEC2",
                }
            )
            accessors.append(
                {
                    "bufferView": idx_view,
                    "componentType": 5123,
                    "count": len(mesh.indices),
                    "type": "SCALAR",
                }
            )
            gltf_meshes.append(
                {
                    "name": name,
                    "primitives": [
                        {
                            "attributes": {"POSITION": ap, "NORMAL": ap + 1, "TEXCOORD_0": ap + 2},
                            "indices": ap + 3,
                            "material": mat_i,
                        }
                    ],
                }
            )

        align4(blob)
        gltf = {
            "asset": {"version": "2.0", "generator": self.generator},
            "scene": 0,
            "scenes": [{"name": scene_name, "nodes": [root]}],
            "nodes": self.nodes,
            "meshes": gltf_meshes,
            "materials": materials,
            "accessors": accessors,
            "bufferViews": views,
            "buffers": [{"byteLength": len(blob)}],
        }
        if images:
            gltf["images"] = images
            gltf["textures"] = textures
            gltf["samplers"] = samplers
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
        return packed


def write_glb(path: Path, data: bytes) -> None:
    path.write_bytes(data)
    print(f"Wrote {path} ({len(data)} bytes)")
