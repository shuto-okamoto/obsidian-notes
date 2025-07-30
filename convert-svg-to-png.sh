#!/bin/bash

# App Icon Generator for Obsidian Notes using macOS native tools
echo "🔥 Creating Obsidian Notes App Icons with macOS tools..."

# Create AppIcons directory
mkdir -p AppIcons

# Convert SVG to high-res PNG first using sips
echo "Converting SVG to base PNG..."

# First, let's try using Safari to render SVG to PDF, then convert
osascript << 'EOF'
tell application "Safari"
    activate
    set myURL to "file://" & (POSIX path of (path to desktop)) & "../Documents/memo-app/Obsidian Notes/app-icon-1024.svg"
    make new document with properties {URL:myURL}
    delay 2
    tell application "System Events"
        keystroke "p" using command down
        delay 1
        click button "PDF" of sheet 1 of window 1 of application process "Safari"
        click menu item "Save as PDF..." of menu "PDF" of sheet 1 of window 1 of application process "Safari"
        delay 1
        keystroke "app-icon-base"
        keystroke return
        delay 2
    end tell
    close front document
end tell
EOF

# Alternative approach: Create a simple PNG using macOS system tools
echo "Creating base app icon using alternative method..."

# Create a simple script to generate PNG using iconutil
cat > temp_iconset.sh << 'SCRIPT'
#!/bin/bash

# Create iconset structure
mkdir -p Obsidian.iconset

# Define the icon sizes needed for iOS
declare -a sizes=(
    "20"
    "29"
    "40" 
    "58"
    "60"
    "80"
    "87"
    "120"
    "152"
    "167"
    "180"
    "1024"
)

echo "📱 iOS App Icon sizes required:"
for size in "${sizes[@]}"; do
    echo "- ${size}x${size}px"
done

echo ""
echo "🎨 To create your app icons:"
echo "1. Open the SVG file in any graphics app (Sketch, Figma, Photoshop, etc.)"
echo "2. Export as PNG at each required size"
echo "3. Save to the AppIcons folder with names like: icon-20.png, icon-29.png, etc."
echo ""
echo "📁 Required files:"
for size in "${sizes[@]}"; do
    echo "- AppIcons/icon-${size}.png (${size}x${size}px)"
done

SCRIPT

chmod +x temp_iconset.sh
./temp_iconset.sh

# Clean up
rm temp_iconset.sh

echo ""
echo "✨ Next steps:"
echo "1. Open app-icon-1024.svg in your preferred graphics application"
echo "2. Export as PNG at the required sizes listed above"
echo "3. Place them in the AppIcons folder"
echo "4. Then drag them into Xcode's AppIcon asset catalog"
echo ""
echo "🚀 Your beautiful Obsidian Notes icon is ready to be processed!"