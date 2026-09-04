#!/usr/bin/env python3
"""Render .github/demo.gif, the loop that shows what this repository does.

Each frame is one screenshot of demo_frames.html?f=N, so the animation is
described in one place and every frame is drawn by the same code. Chrome is
driven headless; nothing is installed and nothing is uploaded.

    python .github/build_demo_gif.py

Needs Chrome and Pillow.
"""

import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    sys.exit("  Pillow is not installed: pip install pillow")

HERE = Path(__file__).resolve().parent
PAGE = HERE / "demo_frames.html"
OUT = HERE / "demo.gif"
FRAMES = 32

CHROME = [
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "google-chrome",
    "chromium",
]

# Most frames are a typing beat. The three long holds are the ones a reader
# needs: the starting state, the moment the build finishes, and the result.
HOLD = {0: 800, 3: 300, 6: 340, 11: 700, 14: 340,
        19: 760, 25: 260, 31: 2300}
BEAT = 110


def chrome():
    for c in CHROME:
        if Path(c).exists() or shutil.which(c):
            return c
    sys.exit("  Chrome was not found. Install it, or add its path to CHROME.")


def main():
    if not PAGE.exists():
        sys.exit(f"  {PAGE.name} is missing.")
    exe = chrome()
    cache = Path(tempfile.mkdtemp(prefix="resume-engine-gif-"))
    shots = []

    for f in range(FRAMES):
        shot = cache / f"f{f:02d}.png"
        subprocess.run(
            [exe, "--headless", "--disable-gpu", "--hide-scrollbars",
             "--force-device-scale-factor=1", "--window-size=900,506",
             f"--screenshot={shot}", f"{PAGE.as_uri()}?f={f}"],
            check=True, capture_output=True, timeout=120)
        shots.append(shot)
        print(f"\r  frame {f + 1} of {FRAMES}", end="", flush=True)
    print()

    images = [Image.open(s).convert("RGB") for s in shots]
    # One shared palette across every frame, so the flat panels do not shimmer
    # from frame to frame the way a per-frame palette makes them.
    palette = images[-1].quantize(colors=160, method=Image.MEDIANCUT)
    frames = [im.quantize(palette=palette, dither=Image.Dither.NONE)
              for im in images]

    frames[0].save(
        OUT, save_all=True, append_images=frames[1:],
        duration=[HOLD.get(i, BEAT) for i in range(FRAMES)],
        loop=0, optimize=True, disposal=2)

    shutil.rmtree(cache, ignore_errors=True)
    kb = OUT.stat().st_size / 1024
    print(f"  {OUT.name}: {FRAMES} frames, {images[0].size[0]}x"
          f"{images[0].size[1]}, {kb:.0f} KB")
    if kb > 5000:
        print("  Over 5 MB. LinkedIn will not animate it; cut frames or colours.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
