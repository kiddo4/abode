#!/usr/bin/env python3
"""Rewrite a .glb so its external texture URIs become embedded bufferView images.

Glint loads embedded PNG/JPEG textures only; Kenney's kits ship GLBs that
reference a shared `Textures/colormap.png` next to the model, which renders as
garbage when the file is copied on its own. This inlines the referenced image
so each model is self-contained.

Usage: embed_glb_textures.py <texture-root> <glb> [<glb> ...]
"""
import json
import os
import struct
import sys

JSON_CHUNK = 0x4E4F534A
BIN_CHUNK = 0x004E4942
MIME = {".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg"}


def read_chunks(data):
    magic, version, _ = struct.unpack_from("<4sII", data, 0)
    if magic != b"glTF":
        raise ValueError("missing GLB magic header")
    chunks, offset = {}, 12
    while offset < len(data):
        length, kind = struct.unpack_from("<II", data, offset)
        chunks[kind] = data[offset + 8 : offset + 8 + length]
        offset += 8 + length + (-length % 4)
    return version, chunks


def pad(buf, fill=b"\x00"):
    return buf + fill * (-len(buf) % 4)


def embed(path, texture_root):
    data = open(path, "rb").read()
    version, chunks = read_chunks(data)
    gltf = json.loads(chunks[JSON_CHUNK])
    binary = bytearray(chunks.get(BIN_CHUNK, b""))

    images = gltf.get("images", [])
    external = [i for i in images if "uri" in i]
    if not external:
        return "already embedded"

    for image in external:
        uri = image.pop("uri")
        source = os.path.join(texture_root, uri)
        if not os.path.exists(source):
            source = os.path.join(texture_root, os.path.basename(uri))
        if not os.path.exists(source):
            raise FileNotFoundError(f"{path}: texture {uri} not found under {texture_root}")
        payload = open(source, "rb").read()

        # bufferViews must be 4-byte aligned; pad the BIN chunk before appending.
        while len(binary) % 4:
            binary.append(0)
        offset = len(binary)
        binary.extend(payload)

        gltf.setdefault("bufferViews", []).append(
            {"buffer": 0, "byteOffset": offset, "byteLength": len(payload)}
        )
        image["bufferView"] = len(gltf["bufferViews"]) - 1
        image["mimeType"] = MIME[os.path.splitext(source)[1].lower()]

    while len(binary) % 4:
        binary.append(0)
    buffers = gltf.setdefault("buffers", [{}])
    buffers[0] = {"byteLength": len(binary)}

    json_chunk = pad(json.dumps(gltf, separators=(",", ":")).encode("utf-8"), b" ")
    bin_chunk = pad(bytes(binary))
    body = (
        struct.pack("<II", len(json_chunk), JSON_CHUNK)
        + json_chunk
        + struct.pack("<II", len(bin_chunk), BIN_CHUNK)
        + bin_chunk
    )
    out = struct.pack("<4sII", b"glTF", version, 12 + len(body)) + body
    open(path, "wb").write(out)
    return f"embedded {len(external)} texture(s), {len(out)} bytes"


if __name__ == "__main__":
    root, targets = sys.argv[1], sys.argv[2:]
    for target in targets:
        print(f"{os.path.basename(target)}: {embed(target, root)}")
