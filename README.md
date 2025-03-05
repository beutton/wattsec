TO-DO: Add app icon here

# WattSec

TO-DO: Add preview here

Display macOS power usage (watts) in the menu bar

## Download

The latest release WattSec.dmg is available here. Open and drag the app to the Applications folder.

## Compile

```bash
git clone https://github.com/beutton/wattsec.git
cd wattsec
./build.sh
open dist/WattSec.app
```

## Settings

- **Detail** - The number of watt decimal places to show (0, 1, or 2)
- **Pace** - The refresh interval (1s, 3s, or 5s)
- **Width** - The width of the metric in the menu bar (Dynamic or Fixed)

## Credit

- [Stats](https://github.com/exelban/stats) for SMC polling
