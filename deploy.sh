#!/usr/bin/env bash

# Ορισμός του φακέλου προορισμού του NixOS
TARGET_DIR="/etc/nixos"

# 1. Έλεγχος αν το script εκτελείται από τον φάκελο που έχει τα αρχεία σου
if [ ! -f "configuration.nix" ] || [ ! -f "flake.nix" ]; then
    echo "❌ Σφάλμα: Δεν βρέθηκαν τα αρχεία configuration.nix ή flake.nix στον τρέχοντα φάκελο."
    echo "Σιγουρέψου ότι τρέχεις το script μέσα από τον φάκελο των dotfiles σου."
    exit 1
fi

echo "🔄 Αντιγραφή αρχείων ρυθμίσεων στο $TARGET_DIR..."

# 2. Αντιγραφή των βασικών αρχείων με sudo
sudo cp configuration.nix "$TARGET_DIR/"
sudo cp flake.nix "$TARGET_DIR/"

# Αντιγραφή και του services.nix αν υπάρχει στον φάκελο
if [ -f "services.nix" ]; then
    echo "📦 Βρέθηκε το services.nix, αντιγραφή..."
    sudo cp services.nix "$TARGET_DIR/"
fi

echo "✅ Η αντιγραφή ολοκληρώθηκε με επιτυχία!"

# 3. Αυτόματο git add (Κρίσιμο για τα Flakes αν ο /etc/nixos είναι Git repo)
if [ -d "$TARGET_DIR/.git" ]; then
    echo "⚙️  Εντοπίστηκε Git repository στο $TARGET_DIR. Προσθήκη αρχείων..."
    cd "$TARGET_DIR" || exit
    sudo git add configuration.nix flake.nix
    if [ -f "services.nix" ]; then
        sudo git add services.nix
    fi
    # Επιστροφή στον αρχικό φάκελο
    cd - > /dev/null || exit
fi

# 4. Ερώτηση για άμεσο Rebuild του συστήματος
echo "------------------------------------------------"
read -p "🤔 Θέλεις να εφαρμόσεις τις αλλαγές στο σύστημα τώρα; (y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "🚀 Εκκίνηση του ολικού συστήματος (nixos-rebuild switch)..."
    sudo nixos-rebuild switch --flake /etc/nixos/#nixos
else
    echo "👍 Έτοιμος! Τα αρχεία μεταφέρθηκαν αλλά δεν εφαρμόστηκαν ακόμα."
fi#!/usr/bin/env bash

# Ορισμός του φακέλου προορισμού του NixOS
TARGET_DIR="/etc/nixos"

# 1. Έλεγχος αν το script εκτελείται από τον φάκελο που έχει τα αρχεία σου
if [ ! -f "configuration.nix" ] || [ ! -f "flake.nix" ]; then
    echo "❌ Σφάλμα: Δεν βρέθηκαν τα αρχεία configuration.nix ή flake.nix στον τρέχοντα φάκελο."
    echo "Σιγουρέψου ότι τρέχεις το script μέσα από τον φάκελο των dotfiles σου."
    exit 1
fi

echo "🔄 Αντιγραφή αρχείων ρυθμίσεων στο $TARGET_DIR..."

# 2. Αντιγραφή των βασικών αρχείων με sudo
sudo cp configuration.nix "$TARGET_DIR/"
sudo cp flake.nix "$TARGET_DIR/"

# Αντιγραφή και του services.nix αν υπάρχει στον φάκελο
if [ -f "services.nix" ]; then
    echo "📦 Βρέθηκε το services.nix, αντιγραφή..."
    sudo cp services.nix "$TARGET_DIR/"
fi

echo "✅ Η αντιγραφή ολοκληρώθηκε με επιτυχία!"

# 3. Αυτόματο git add (Κρίσιμο για τα Flakes αν ο /etc/nixos είναι Git repo)
if [ -d "$TARGET_DIR/.git" ]; then
    echo "⚙️  Εντοπίστηκε Git repository στο $TARGET_DIR. Προσθήκη αρχείων..."
    cd "$TARGET_DIR" || exit
    sudo git add configuration.nix flake.nix
    if [ -f "services.nix" ]; then
        sudo git add services.nix
    fi
    # Επιστροφή στον αρχικό φάκελο
    cd - > /dev/null || exit
fi

# 4. Ερώτηση για άμεσο Rebuild του συστήματος
echo "------------------------------------------------"
read -p "🤔 Θέλεις να εφαρμόσεις τις αλλαγές στο σύστημα τώρα; (y/N): " choice

if [[ "$choice" =~ ^[Yy]$ ]]; then
    echo "🚀 Εκκίνηση του ολικού συστήματος (nixos-rebuild switch)..."
    sudo nixos-rebuild switch --flake /etc/nixos/#nixos
else
    echo "👍 Έτοιμος! Τα αρχεία μεταφέρθηκαν αλλά δεν εφαρμόστηκαν ακόμα."
fi
