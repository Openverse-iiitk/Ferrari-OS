#!/usr/bin/env bash
set -euo pipefail
# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directory setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$ROOT_DIR/configs"
PACKAGE_DIR="$CONFIG_DIR/packages"
WORK_DIR="$ROOT_DIR/work"
OUT_DIR="$ROOT_DIR/out"

# Create package directory if it doesn't exist
mkdir -p "$PACKAGE_DIR"

# Create required directories
mkdir -p configs/airootfs/usr/local/bin
mkdir -p configs/airootfs/usr/share/bash-completion/completions
mkdir -p configs/airootfs/etc/profile.d

# Create Ferrari OS aliases file
cat > "$CONFIG_DIR/airootfs/etc/profile.d/pit-aliases.sh" << 'EOL'
# Ferrari OS package manager aliases
alias update='pit -Syu'
alias install='pit -S'
alias remove='pit -R'
alias search='pit -Ss'
alias clean='pit -Sc'
alias info='pit -Si'
alias packages='pit -Q'
EOL

# Set permissions
chmod +x configs/airootfs/usr/local/bin/pit
chmod 644 configs/airootfs/usr/share/bash-completion/completions/pit
chmod 644 configs/airootfs/etc/profile.d/pit-aliases.sh
# Check for required package files
REQUIRED_FILES=("base.txt" "desktop.txt" "development.txt" "multimedia.txt")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$PACKAGE_DIR/$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required package files:${NC}"
    printf "${YELLOW}%s${NC}\n" "${MISSING_FILES[@]}"
    exit 1
fi

# Combine all package lists
echo -e "${BLUE}Gathering packages from:${NC}"
for file in "${REQUIRED_FILES[@]}"; do
    echo -e "${GREEN}- $file${NC}"
done

PACKAGES=""
for file in "${REQUIRED_FILES[@]}"; do
    # Extract packages, ignoring comments and empty lines
    FILE_PACKAGES=$(grep -v '^#' "$PACKAGE_DIR/$file" | grep -v '^$' | awk '{print $1}' | tr '\n' ' ')
    PACKAGES+="$FILE_PACKAGES "
done

# Clean previous build
if [ -d "$WORK_DIR" ]; then
    echo -e "${BLUE}Cleaning previous build...${NC}"
    rm -rf "$WORK_DIR"
fi

if [ ! -f "$CONFIG_DIR/airootfs/usr/local/bin/pit" ]; then
    echo -e "${RED}Error: pit wrapper not created successfully${NC}"
    exit 1
fi

if [ ! -f "$CONFIG_DIR/airootfs/usr/share/bash-completion/completions/pit" ]; then
    echo -e "${RED}Error: pit completion not created successfully${NC}"
    exit 1
fi

# Verify permissions
if [ ! -x "$CONFIG_DIR/airootfs/usr/local/bin/pit" ]; then
    echo -e "${RED}Error: pit wrapper is not executable${NC}"
    exit 1
fi

# Build ISO
echo -e "${GREEN}Building Ferrari OS ISO...${NC}"
echo -e "${BLUE}Total packages to be installed: $(echo $PACKAGES | wc -w)${NC}"
# Add to build_iso.sh before mkarchiso
# Verify pit setup
if [ ! -f "$CONFIG_DIR/airootfs/usr/local/bin/pit" ]; then
    echo -e "${RED}Error: pit wrapper not created successfully${NC}"
    exit 1
fi

if [ ! -f "$CONFIG_DIR/airootfs/usr/share/bash-completion/completions/pit" ]; then
    echo -e "${RED}Error: pit completion not created successfully${NC}"
    exit 1
fi

# Verify permissions
if [ ! -x "$CONFIG_DIR/airootfs/usr/local/bin/pit" ]; then
    echo -e "${RED}Error: pit wrapper is not executable${NC}"
    exit 1
fi

THREADS=$(nproc)
MEM_GB=$(free -g | awk '/^Mem:/{print $2}')
WORK_DIR_ORIG="$WORK_DIR"

# Use tmpfs if enough RAM (>16GB)
if [ "$MEM_GB" -gt 16 ]; then
    echo -e "${BLUE}Using tmpfs for faster building...${NC}"
    WORK_DIR="/tmp/archiso-tmp"
    sudo mkdir -p "$WORK_DIR"
    sudo mount -t tmpfs -o size=12G tmpfs "$WORK_DIR"
    sudo chown "$(whoami)":"$(whoami)" "$WORK_DIR"
fi

# Build optimizations
export MAKEFLAGS="-j$THREADS"
export COMPRESSION="zstd"  # Faster than xz
export COMPRESSION_OPTS="-T$THREADS --long=19"
export AIROOTFS_IMAGE_TOOL_OPTIONS="-comp zstd -Xcompression-level 15"

echo -e "${BLUE}Building with optimizations:${NC}"
echo -e "${GREEN}- Using $THREADS threads${NC}"
echo -e "${GREEN}- Using zstd compression${NC}"
[ "$MEM_GB" -gt 16 ] && echo -e "${GREEN}- Using tmpfs workspace${NC}"

# Build ISO
mkarchiso -v \
    -w "$WORK_DIR" \
    -o "$OUT_DIR" \
    -p "$PACKAGES" \
    "$CONFIG_DIR"

# Cleanup tmpfs if used
if [ "$MEM_GB" -gt 16 ]; then
    sudo umount "$WORK_DIR"
    rm -rf "$WORK_DIR"
fi

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo -e "ISO location: $OUT_DIR"
    ls -lh "$OUT_DIR"/*.iso
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi