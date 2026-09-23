#!/bin/bash

APP_ID="org.kde.prayertimes"
VERSION="1.0.2"

echo "========================================="
echo "Prayer Times Plasmoid - Build & Install"
echo "========================================="

# Function to check if the plasmoid is already installed
is_installed() {
    kpackagetool6 --type=Plasma/Applet --list 2>/dev/null | grep -q "$APP_ID"
}

# Function to build translations
build_translations() {
    echo ""
    echo "1. Building translations for all languages..."
    
    # Find all .po files in po/ directory or subdirectories
    find po/ -name "*.po" 2>/dev/null | while read -r po_file; do
        # Extract language code from file path or name
        lang=$(basename "$po_file" .po)
        lang=${lang#plasma_applet_${APP_ID}_}
        
        # If filename still contains full app ID, extract from directory
        if [[ "$lang" == *"plasma_applet"* ]] || [[ "$lang" == "$APP_ID" ]]; then
            lang=$(basename "$(dirname "$po_file")")
        fi
        
        # Validate language code
        if [[ -z "$lang" ]] || [[ "$lang" == "po" ]]; then
            continue
        fi
        
        echo "   - Compiling translation: $lang ($po_file)"
        
        # Create target directory for this language inside contents/locale/
        target_dir="contents/locale/${lang}/LC_MESSAGES"
        mkdir -p "$target_dir"
        
        # Compile .po to .mo
        if msgfmt "$po_file" -o "${target_dir}/plasma_applet_${APP_ID}.mo" 2>/dev/null; then
            echo "     ✓ Successfully compiled"
        else
            echo "     ✗ Failed to compile (is gettext installed?)"
        fi
    done
    
    echo "   ✓ Translation build complete"
}

# Function to create plasmoid package
create_package() {
    echo ""
    echo "2. Creating plasmoid package..."
    
    PACKAGE_NAME="${APP_ID}-v${VERSION}.plasmoid"
    rm -f "$PACKAGE_NAME"
    
    if zip -r "$PACKAGE_NAME" \
        contents/ \
        metadata.json \
        LICENSE \
        README.md \
        -x "*.git*" "po/*" "build.sh" "*.sh" 2>/dev/null; then
        echo "   ✓ Package created: $PACKAGE_NAME"
    else
        echo "   ✗ Failed to create package"
        return 1
    fi
}

# Function to install the plasmoid (Fresh Install)
install_plasmoid() {
    echo ""
    echo "3. Installing plasmoid (Fresh Install)..."
    
    PACKAGE_NAME="${APP_ID}-v${VERSION}.plasmoid"
    
    if [[ ! -f "$PACKAGE_NAME" ]]; then
        echo "   ✗ Package not found: $PACKAGE_NAME"
        echo "   Please run build step first."
        return 1
    fi
    
    # Install using kpackagetool6
    if kpackagetool6 --type=Plasma/Applet --install "$PACKAGE_NAME" 2>/dev/null; then
        echo "   ✓ Plasmoid installed successfully"
    else
        echo "   ✗ Installation failed"
        echo "   Trying manual installation..."
        
        # Fallback: manual installation
        INSTALL_DIR="$HOME/.local/share/plasma/plasmoids/${APP_ID}"
        rm -rf "$INSTALL_DIR"
        mkdir -p "$INSTALL_DIR"
        
        if unzip -q "$PACKAGE_NAME" -d "$INSTALL_DIR"; then
            echo "   ✓ Manual installation successful"
        else
            echo "   ✗ Manual installation failed"
            return 1
        fi
    fi
}

# Function to upgrade the plasmoid
upgrade_plasmoid() {
    echo ""
    echo "3. Upgrading plasmoid..."
    
    PACKAGE_NAME="${APP_ID}-v${VERSION}.plasmoid"
    
    if [[ ! -f "$PACKAGE_NAME" ]]; then
        echo "   ✗ Package not found: $PACKAGE_NAME"
        echo "   Please run build step first."
        return 1
    fi
    
    # Upgrade using kpackagetool6
    if kpackagetool6 --type=Plasma/Applet --upgrade "$PACKAGE_NAME" 2>/dev/null; then
        echo "   ✓ Plasmoid upgraded successfully"
    else
        echo "   ✗ Upgrade failed"
        return 1
    fi
}

# Function to install translations into the plasmoid's own directory
install_translations() {
    echo ""
    echo "4. Installing translations..."
    
    # Target directory inside the installed plasmoid
    TARGET_DIR="$HOME/.local/share/plasma/plasmoids/${APP_ID}/contents/locale"
    mkdir -p "$TARGET_DIR"
    
    # Copy compiled translations from the local build directory
    if [[ -d "contents/locale" ]]; then
        cp -r contents/locale/* "$TARGET_DIR/" 2>/dev/null
        echo "   ✓ Translations installed to: $TARGET_DIR"
    else
        echo "   ⚠ No translations found (contents/locale/ directory missing)"
    fi
}

# Function to rebuild Plasma cache and restart Plasma
rebuild_cache() {
    echo ""
    echo "5. Rebuilding Plasma cache and restarting Plasma..."
    
    if kbuildsycoca6 --noincremental 2>/dev/null; then
        echo "   ✓ Cache rebuilt successfully"
    else
        echo "   ⚠ Cache rebuild failed"
    fi
    
    echo "   Restarting Plasma shell..."
    if kquitapp6 plasmashell 2>/dev/null; then
        sleep 2 # Give it a moment to fully quit
        if kstart plasmashell 2>/dev/null; then
            echo "   ✓ Plasma restarted successfully"
        else
            echo "   ⚠ Failed to start Plasma. You may need to log out and log back in."
        fi
    else
        echo "   ⚠ Failed to quit Plasma. You may need to restart it manually."
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --build-only        Only build translations and package (no install/upgrade)"
    echo "  --install-only      Only install existing package (fresh install)"
    echo "  --upgrade           Only upgrade existing installed package"
    echo "  --translations-only Only build and install translations"
    echo "  --no-restart        Don't rebuild Plasma cache and restart after installation"
    echo "  --help              Show this help message"
    echo ""
    echo "Default behavior: Build translations, create package, check if installed,"
    echo "                  then upgrade (if installed) or install (if not), and restart Plasma."
}

# Parse command line arguments
BUILD_ONLY=false
INSTALL_ONLY=false
UPGRADE_ONLY=false
TRANSLATIONS_ONLY=false
NO_RESTART=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --build-only)
            BUILD_ONLY=true
            shift
            ;;
        --install-only)
            INSTALL_ONLY=true
            shift
            ;;
        --upgrade)
            UPGRADE_ONLY=true
            shift
            ;;
        --translations-only)
            TRANSLATIONS_ONLY=true
            shift
            ;;
        --no-restart)
            NO_RESTART=true
            shift
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main execution flow
echo ""

if [[ "$INSTALL_ONLY" == true ]]; then
    install_plasmoid
    install_translations
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
elif [[ "$UPGRADE_ONLY" == true ]]; then
    upgrade_plasmoid
    install_translations
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
elif [[ "$TRANSLATIONS_ONLY" == true ]]; then
    build_translations
    install_translations
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
elif [[ "$BUILD_ONLY" == true ]]; then
    build_translations
    create_package
else
    # Default behavior: Build, then check if installed to decide between upgrade or fresh install
    build_translations
    create_package
    
    if is_installed; then
        echo ""
        echo "   ℹ️  Plasmoid is already installed. Performing upgrade..."
        upgrade_plasmoid
    else
        echo ""
        echo "   ℹ️  Plasmoid is not installed. Performing fresh installation..."
        install_plasmoid
    fi
    
    install_translations
    
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
fi

echo ""
echo "========================================="
echo "Build & Install Complete!"
echo "========================================="

if [[ "$BUILD_ONLY" == false ]] && [[ "$NO_RESTART" == false ]]; then
    echo ""
    echo "ℹ️  Plasma has been restarted."
    echo "   If the widget does not appear, please log out and log back in."
fi

if [[ "$BUILD_ONLY" == true ]]; then
    echo ""
    echo "📦 Package created: ${APP_ID}-v${VERSION}.plasmoid"
    echo "   To install manually, run:"
    echo "   kpackagetool6 --type=Plasma/Applet --install ${APP_ID}-v${VERSION}.plasmoid"
    echo "   To upgrade manually, run:"
    echo "   kpackagetool6 --type=Plasma/Applet --upgrade ${APP_ID}-v${VERSION}.plasmoid"
fi

echo ""
