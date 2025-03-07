<p align="center">
<img src="https://github.com/user-attachments/assets/ed040304-5689-4323-b9c0-c9355b9c4365" width="200"/>
</p>

# WattSec

<p align="center">
<img src="https://github.com/user-attachments/assets/1d444659-dbe0-48d1-9368-a79d10ccf8c5"/>
</p>

Display macOS power usage (wattage) in the menu bar

## Download

The latest release of WattSec is available [here](https://github.com/beutton/wattsec/releases/latest). Open the DMG and drag the app to the Applications folder.

## Compile

```bash
git clone https://github.com/beutton/wattsec.git
cd wattsec
./build.sh
open dist/WattSec.app
```

## Settings

<p align="center">
<img src="https://github.com/user-attachments/assets/9d213036-225c-4369-9b18-1cb6b94956e1"/>
</p>

- **Detail** - The number of watt decimal places to show (0, 1, or 2)
- **Pace** - The refresh interval (1s, 3s, or 5s)
- **Width** - The width of the metric in the menu bar (Dynamic or Fixed)
- **Launch** - Toggle Launch at Login

## Credit

- [Stats](https://github.com/exelban/stats) for SMC polling
