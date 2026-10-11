from pathlib import Path
from PIL import Image
import sys

root = Path(__file__).parent
paths = sorted((root / (sys.argv[1] if len(sys.argv) > 1 else 'splash_c_clean_frames')).glob('frame_*.png'))
assert len(paths) == 75
frames = []
for index, path in enumerate(paths):
    with Image.open(path) as image:
        frames.append(image.convert('RGB').quantize(colors=256, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))
    if index % 20 == 0:
        print(f'Encoded {index + 1}/75', flush=True)
target = root / (sys.argv[2] if len(sys.argv) > 2 else 'splash_c_clean_preview.gif')
frames[0].save(target, save_all=True, append_images=frames[1:], duration=[60] * 74 + [1100], loop=0, disposal=2, optimize=False)
with Image.open(target) as image:
    duration = 0
    for index in range(image.n_frames):
        image.seek(index)
        duration += image.info['duration']
    print(f'GIF verified: {image.size}, {image.n_frames} frames, {duration} ms', flush=True)
    assert duration == 5540
