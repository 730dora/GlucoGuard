from PIL import Image, ImageOps
import sys

# Paths (relative to repo root)
IN_PATH = 'assets/images/GlucoGuard.png'
OUT_PATH = 'assets/images/GlucoGuard_fullcircle.png'
SIZE = (1024, 1024)

try:
    src = Image.open(IN_PATH).convert('RGBA')
except FileNotFoundError:
    print(f'Input file not found: {IN_PATH}')
    sys.exit(2)

# Create base circle background (white) — you can change color here
bg_color = (255, 255, 255, 255)
background = Image.new('RGBA', SIZE, bg_color)

# Resize source to fit within circle with small padding
# We'll fit the logo so its smaller dimension fills ~78% of canvas
max_dim = int(SIZE[0] * 0.78)

# Trim transparent border if present
bbox = src.getbbox()
if bbox:
    src_cropped = src.crop(bbox)
else:
    src_cropped = src

# Resize preserving aspect ratio
src_cropped.thumbnail((max_dim, max_dim), Image.LANCZOS)

# Create circular mask for final output to enforce perfect circle
mask = Image.new('L', SIZE, 0)
mask_draw = Image.new('L', SIZE, 0)

# draw circle mask using ImageOps.fit trick
circle = Image.new('L', SIZE, 0)
ImageOps.fit(circle, SIZE, centering=(0.5, 0.5))
from PIL import ImageDraw
mask_draw = ImageDraw.Draw(mask)
mask_draw.ellipse((0, 0, SIZE[0], SIZE[1]), fill=255)

# Paste resized logo centered
x = (SIZE[0] - src_cropped.width) // 2
y = (SIZE[1] - src_cropped.height) // 2
background.paste(src_cropped, (x, y), src_cropped)

# Apply circular mask to ensure the canvas is circular (transparent corners)
out = Image.new('RGBA', SIZE, (0,0,0,0))
out.paste(background, (0,0), mask)

# Save as PNG
out.save(OUT_PATH)
print(f'Wrote {OUT_PATH} (size {SIZE[0]}x{SIZE[1]})')
