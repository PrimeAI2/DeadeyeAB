# QUICK START CHECKLIST

## What Was Wrong

❌ **Splash screen not appearing at all**
❌ **Audio (bodies.wav) not playing**
❌ **Button click might be wrong for 4-button scenario**

## Root Cause

The `xxd -i` commands in CMakeLists.txt were using full paths, creating wrong variable names:
- Generated: `assets_overlay_png` 
- Expected: `overlay_png`

This caused all three embedded assets to have **zero length**, preventing splash/audio from loading.

---

## What I Fixed

### 1. CMakeLists.txt
Changed from:
```cmake
xxd -i "${ASSET_DIR}/overlay.png" > output.h
```

To:
```cmake
sh -c "cd ${ASSET_DIR} && xxd -i overlay.png > output.h"
```

### 2. main_complete.mm
- ✅ Added asset validation on startup (shows byte counts)
- ✅ Added comprehensive error logging for splash screen
- ✅ Added comprehensive error logging for audio
- ✅ Fixed text position (bottom of splash screen)
- ✅ Added logging for 4-button detection
- ✅ Confirms which button is being clicked

---

## Build & Run

```bash
# Clean rebuild
rm -rf build
mkdir build && cd build
cmake ..
make

# Run with logging
./DeadeyeBot 2>&1 | tee run.log
```

---

## What You Should See

```
[INIT] Checking embedded assets...
[INIT]   overlay_png: 45231 bytes     ← MUST BE NON-ZERO!
[INIT]   splash_png: 123456 bytes     ← MUST BE NON-ZERO!
[INIT]   bodies_wav: 789012 bytes     ← MUST BE NON-ZERO!
[INIT] ✓ All assets validated

[SPLASH] === INITIALIZING SPLASH SCREEN ===
[SPLASH] ✓ Image loaded: 880x420
[SPLASH] ✓ WINDOW DISPLAYED

[AUDIO] ✓ PLAYING (duration: 25.3s)
```

**Then you should:**
- See a black window with splash image
- See red "Initializing" text at the BOTTOM
- Hear the audio playing
- Text cycles through initialization messages
- After 25 seconds, it starts clicking buttons

---

## If Assets Still Show 0 Bytes

Manually generate them:
```bash
cd assets
xxd -i overlay.png > ../build/generated/overlay_png.h
xxd -i splash.png > ../build/generated/splash_png.h  
xxd -i bodies.wav > ../build/generated/bodies_wav.h
cd ../build
make
```

---

## Send Me

After running, send me:
1. The `run.log` file
2. What you see (or don't see)
3. Any ERROR messages

I can fix any remaining issues immediately!

---

## Files Updated

- ✅ `CMakeLists.txt` - Fixed asset embedding
- ✅ `main_complete.mm` - Added validation & error checking
