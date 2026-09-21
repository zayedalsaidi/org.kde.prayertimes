#!/bin/bash

APP_ID="org.kde.prayertimes"
VERSION="1.0.0"

echo "========================================="
echo "Prayer Times Plasmoid - Build & Install"
echo "========================================="

# Function to build translations
build_translations() {
    echo ""
    echo "1. Building translations for all languages..."
    
    # Find all .po files in po/ directory or subdirectories
    find po/ -name "*.po" 2>/dev/null | while read -r po_file; do
        # Extract language code from file path or name
        # Example: po/ar/plasma_applet_org.kde.prayertimes.po -> ar
        # or: po/ar.po -> ar
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
        
        # Create target directory for this language
        target_dir="locale/${lang}/LC_MESSAGES"
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
        locale/ \
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

# Function to install the plasmoid
install_plasmoid() {
    echo ""
    echo "3. Installing plasmoid..."
    
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

# Function to install translations only
install_translations() {
    echo ""
    echo "4. Installing translations..."
    
    LOCALE_DIR="$HOME/.local/share/locale"
    mkdir -p "$LOCALE_DIR"
    
    # Copy compiled translations
    if [[ -d "locale" ]]; then
        cp -r locale/* "$LOCALE_DIR/" 2>/dev/null
        echo "   ✓ Translations installed to: $LOCALE_DIR"
    else
        echo "   ⚠ No translations found (locale/ directory missing)"
    fi
}

# Function to rebuild Plasma cache
rebuild_cache() {
    echo ""
    echo "5. Rebuilding Plasma cache..."
    
    if kbuildsycoca6 --noincremental 2>/dev/null; then
        echo "   ✓ Cache rebuilt successfully"
    else
        echo "   ⚠ Cache rebuild failed (you may need to restart Plasma manually)"
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --build-only        Only build translations and package (no install)"
    echo "  --install-only      Only install existing package and translations"
    echo "  --translations-only Only build and install translations"
    echo "  --no-restart        Don't rebuild Plasma cache after installation"
    echo "  --help              Show this help message"
    echo ""
    echo "Default behavior: Build translations, create package, install, and restart Plasma"
}

# Parse command line arguments
BUILD_ONLY=false
INSTALL_ONLY=false
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
    # Only install existing package
    install_plasmoid
    install_translations
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
elif [[ "$TRANSLATIONS_ONLY" == true ]]; then
    # Only build and install translations
    build_translations
    install_translations
    if [[ "$NO_RESTART" == false ]]; then
        rebuild_cache
    fi
elif [[ "$BUILD_ONLY" == true ]]; then
    # Only build, don't install
    build_translations
    create_package
else
    # Full build and install (default)
    build_translations
    create_package
    install_plasmoid
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
    echo "ℹ️  Plasma will restart automatically."
    echo "   If it doesn't, please log out and log back in."
fi

if [[ "$BUILD_ONLY" == true ]]; then
    echo ""
    echo "📦 Package created: ${APP_ID}-v${VERSION}.plasmoid"
    echo "   To install manually, run:"
    echo "   kpackagetool6 --type=Plasma/Applet --install ${APP_ID}-v${VERSION}.plasmoid"
fi

echo ""
