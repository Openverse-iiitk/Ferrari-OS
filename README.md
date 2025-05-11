# Ferrari OS 🚗🔥

**Ferrari OS** is a bleeding-edge, high-performance Arch-based Linux distribution inspired by the speed, elegance, and prestige of Ferrari culture. Designed for power users, developers, and enthusiasts who demand blazing speed, visual sophistication, and absolute control. 


---

## ✨ Features
- **Ferrari-Branded UI**: Red-black custom themes, wallpapers, boot splash, and icon set.
- **Hyprland / KDE Desktop**: Lightning-fast, animated, stylish UIs.
- **ZSH + Starship Prompt**: Beautiful, fast shell with performance info.
- **Garage Toolkit**: A custom command-line control center.
- **Post-Install Wizard**: For quick personalization and optimization.
- **Performance Mode**: Toggle CPU governors, compositors, and services.
- **BTRFS with Snapper**: Automatic snapshot & rollback support.

---

## 🛠️ Build Instructions
Clone and build Ferrari OS ISO using ArchISO:
Run `sudo pacman -Syu` . Then,

```bash
git clone https://github.com/Openverse-iiitk/Ferrari-OS.git
cd Ferrari-OS
sudo pacman -S archiso
sudo ./scripts/build_iso.sh
```

Test using QEMU:
You can download qemu [here](https://www.qemu.org/download/). It's similar to virtual box and vmware. More native support for kernel-based virtual machines. You can also install virt-manager to run qemu with friendly gui. Or use the cli way as below.
```bash
qemu-system-x86_64 -m 4G -boot d -cdrom out/Ferrari-OS.iso
```

---

## 📂 Project Structure
- `configs/` → ArchISO config files and customizations
- `scripts/` → Automation and ISO build scripts
- `docs/` → Installation, contribution, and philosophy
- `.github/workflows/` → CI pipeline to auto-build ISOs

---

## 🤝 Contributing
We are a opensource developers group and we welcome new contributors.
Check [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for how to get started.

---

## 📅 Roadmap (Summary)
- **May** – Core ISO, branding setup, contributor pipeline
- **June** – Custom installer, performance tuning, UX polish
- **July** – Testing, documentation, official release

---

## 📸 Screenshots
> Coming soon: Ferrari boot, desktop, and control center

---

## 🔗 License
MIT License

---

## 💬 Join the Ferrari OS Garage
Join our Discord, Matrix, or follow us on GitHub for updates.

> _"Drive fast. Boot faster."_
