# Button Click Logic - 4 Orange Buttons

## Current Implementation

The code is designed to click the **SECOND** orange button out of 4 total buttons.

### Detection Process

1. **Find all orange buttons** using HSV color detection:
   - HSV range: (1,140,120) to (21,255,255)
   - Minimum area: 450 pixels
   - Aspect ratio: 1.3 to 4.5
   - Location: Right 65% of screen only

2. **Sort by Y position** (top to bottom)

3. **Click the SECOND button** (index 1):
   ```cpp
   if (btns.size() >= 2) {
       const cv::Rect r = btns[1].r;  // Second button
       ...
   }
   ```

### Click Calculation

For the second button:
```cpp
int fx = r.x + (r.width * 0.65) + 10;   // 65% across + 10px right
int fy = r.y + r.height/2 + 15 + 20;    // Center + 35px down
```

**Example:**
- Button rect: (130, 280, 40×40)
- Button center: (150, 300)
- Click target: (156, 315) ← 6px right, 15px down from center

### Retry Logic

If first click doesn't work, tries 5 Y offsets:
- Original position (dy=0)
- +12px down (dy=+12)
- -12px up (dy=-12)
- +20px down (dy=+20)
- -20px up (dy=-20)

---

## Console Output

You'll see:
```
[STARTUP] Found 4 orange buttons (need >= 2)
[STARTUP] Targeting SECOND button (btns[1])
[DEBUG] Second button (btns[1]): rect=(130,280,40x40)
[DEBUG] Calculated click: fx=156 fy=315 (bias=0.65 yOffset=15.0)
[PLAY] aiming second button at radar(156,315) (dy=0)
[CLICK] radar(156,315) -> screen(1234,567)
```

---

## Potential Issues

### Issue 1: Not detecting all 4 buttons

**Symptom:**
```
[STARTUP] Found 2 orange buttons (need >= 2)
```

**Possible causes:**
- HSV range too narrow
- Buttons too small (< 450px area)
- Buttons in left 35% of screen (filtered out)

**Fix options:**

**Option A - Widen HSV range:**
```cpp
// Line 53-54
static const cv::Scalar BTN_HSV_LOW ( 0,100,100);  // was (1,140,120)
static const cv::Scalar BTN_HSV_HIGH(25,255,255);  // was (21,255,255)
```

**Option B - Lower area threshold:**
```cpp
// Line 416
if(a<200) continue;  // was 450
```

**Option C - Remove position filter:**
```cpp
// Line 420 - comment out:
// if(r.x < int(bgr.cols*0.35)) continue;
```

---

### Issue 2: Clicking wrong button

**If you want to click a DIFFERENT button:**

**Click FIRST button instead:**
```cpp
// Line 476
if (btns.size() >= 1) {           // was: >= 2
    const cv::Rect r = btns[0].r;  // was: btns[1]
```

**Click THIRD button:**
```cpp
// Line 476
if (btns.size() >= 3) {           // was: >= 2
    const cv::Rect r = btns[2].r;  // was: btns[1]
```

**Click LAST button (4th):**
```cpp
// Line 476
if (btns.size() >= 4) {
    const cv::Rect r = btns[3].r;  // Last one
```

---

### Issue 3: Click offset wrong

**Current offset:** 65% across, 35px down from center

**To click DEAD CENTER instead:**
```cpp
// Line 478-479
int fx = r.x + r.width/2;   // was: r.x + (r.width * 0.65) + 10
int fy = r.y + r.height/2;  // was: r.y + r.height/2 + 15 + 20
```

**To adjust the bias:**
```cpp
// Line 59 - change from 0.65 to something else:
static double g_btnBiasX = 0.50;  // 0.50 = center, 0.65 = 65% across

// Or use command line:
./DeadeyeBot --btn-x-bias 0.50 --btn-y-offset 0
```

---

### Issue 4: Need to click multiple buttons

**If you need to click button 1 THEN button 2:**

Replace the button clicking section with:
```cpp
// Click first button
if (btns.size() >= 1) {
    auto r = btns[0].r;
    int fx = r.x + r.width/2;
    int fy = r.y + r.height/2;
    std::cout << "[CLICK] Button 0 at (" << fx << "," << fy << ")\n";
    click_once_radar((float)fx, (float)fy);
    std::this_thread::sleep_for(800ms);
}

// Click second button
if (btns.size() >= 2) {
    auto r = btns[1].r;
    int fx = r.x + r.width/2;
    int fy = r.y + r.height/2;
    std::cout << "[CLICK] Button 1 at (" << fx << "," << fy << ")\n";
    click_once_radar((float)fx, (float)fy);
    std::this_thread::sleep_for(800ms);
}
```

---

## Debug Window

The debug window shows:
- ✅ Green rectangles = detected buttons
- ✅ Cyan/yellow rectangle = second button (target)
- ✅ Red crosshair = cannon position

Check this window to visually confirm:
1. Are all 4 buttons being detected?
2. Is the right button highlighted in cyan?
3. Is the click position reasonable?

---

## What I Need From You

After running the app with the new logging, tell me:

1. **How many buttons does it detect?**
   ```
   [STARTUP] Found ___ orange buttons
   ```

2. **Is it clicking the right button?**
   - First (top)?
   - Second?
   - Third?
   - Fourth (bottom)?

3. **Does the click work?**
   - Button disappears after click?
   - Game transitions to next screen?
   - Nothing happens?

4. **Screenshot of debug window** showing:
   - All detected buttons
   - Which one is highlighted
   - Where the click target is

With this info, I can fine-tune the exact button and click position!
