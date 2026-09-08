#!/usr/bin/env python3
"""Download CC0 Poly Haven 1k textures/models used by the camp kit.

Assets are CC0 (public domain). Poly Haven asks that tools using the live API
credit them; see third_party/polyhaven/ATTRIBUTION.md.
"""

from __future__ import annotations

import json
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "third_party" / "polyhaven"
UA = "Line7CampKit/1.0 (https://github.com/myat93/line7)"

TEXTURES = {
    "pine_bark": ("bark", ("Diffuse", "nor_gl", "Rough")),
    "brown_planks_07": ("plank", ("Diffuse", "nor_gl", "Rough")),
    "mud_forest": ("mud", ("Diffuse", "nor_gl", "Rough")),
    "hessian_380": ("cloth", ("Diffuse", "nor_gl", "Rough")),
    "brown_leather": ("leather", ("Diffuse", "nor_gl", "Rough")),
}

MODELS = (
    "wooden_crate_01",
    "wine_barrel_01",
    "wooden_lantern_01",
    "wooden_bucket_01",
    "wooden_axe_02",
    "brass_pot_01",
)


def get_json(url: str) -> dict:
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read().decode("utf-8"))


def download(url: str, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and dest.stat().st_size > 0:
        print(f"skip {dest}")
        return
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    print(f"GET {url} -> {dest}")
    with urllib.request.urlopen(req, timeout=120) as resp:
        dest.write_bytes(resp.read())


def fetch_texture(asset_id: str) -> dict:
    info = get_json(f"https://api.polyhaven.com/info/{asset_id}")
    files = get_json(f"https://api.polyhaven.com/files/{asset_id}")
    dest_dir = OUT / "textures" / asset_id
    maps = {}
    for map_name in ("Diffuse", "nor_gl", "Rough"):
        payload = files.get(map_name, {}).get("1k", {}).get("jpg")
        if not payload:
            continue
        suffix = {"Diffuse": "diff", "nor_gl": "nor_gl", "Rough": "rough"}[map_name]
        dest = dest_dir / f"{asset_id}_{suffix}_1k.jpg"
        download(payload["url"], dest)
        maps[map_name] = dest.relative_to(ROOT).as_posix()
    return {
        "id": asset_id,
        "name": info.get("name", asset_id),
        "authors": info.get("authors", {}),
        "maps": maps,
    }


def fetch_model(asset_id: str) -> dict:
    info = get_json(f"https://api.polyhaven.com/info/{asset_id}")
    files = get_json(f"https://api.polyhaven.com/files/{asset_id}")
    gltf = files["gltf"]["1k"]["gltf"]
    dest_dir = OUT / "models" / asset_id
    gltf_name = Path(gltf["url"]).name
    download(gltf["url"], dest_dir / gltf_name)
    includes = []
    for rel, payload in (gltf.get("include") or {}).items():
        download(payload["url"], dest_dir / rel)
        includes.append(rel)
    return {
        "id": asset_id,
        "name": info.get("name", asset_id),
        "authors": info.get("authors", {}),
        "gltf": (dest_dir / gltf_name).relative_to(ROOT).as_posix(),
        "include": includes,
    }


def write_attribution(records: list[dict]) -> None:
    lines = [
        "# Poly Haven assets (CC0)",
        "",
        "All files in this folder are [CC0](https://creativecommons.org/publicdomain/zero/1.0/)",
        "from [Poly Haven](https://polyhaven.com). No Elden Ring or other ripped game files.",
        "",
        "Powered by [Poly Haven](https://polyhaven.com) — 1k JPG / glTF downloads via the public API.",
        "",
        "| Asset | Authors | Use |",
        "| --- | --- | --- |",
    ]
    for rec in records:
        authors = ", ".join(rec.get("authors", {}).keys()) or "Poly Haven"
        kind = "model" if "gltf" in rec else "texture"
        lines.append(f"| [{rec['id']}](https://polyhaven.com/a/{rec['id']}) ({kind}) | {authors} | camp / ruins PBR |")
    lines.append("")
    (OUT / "ATTRIBUTION.md").write_text("\n".join(lines), encoding="utf-8")
    (OUT / "manifest.json").write_text(json.dumps(records, indent=2), encoding="utf-8")


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    records: list[dict] = []
    for asset_id in TEXTURES:
        records.append(fetch_texture(asset_id))
    for asset_id in MODELS:
        records.append(fetch_model(asset_id))
    write_attribution(records)
    print(f"Wrote {len(records)} assets under {OUT}")


if __name__ == "__main__":
    main()
