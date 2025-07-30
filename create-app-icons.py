#!/usr/bin/env python3
"""
App Icon Generator for Obsidian Notes
Creates all required iOS app icon sizes from SVG
"""

import subprocess
import os
from pathlib import Path

# iOS App Icon sizes required
ICON_SIZES = [
    (20, "20pt"),
    (29, "29pt"), 
    (40, "40pt"),
    (58, "58pt"),
    (60, "60pt"),
    (80, "80pt"),
    (87, "87pt"),
    (120, "120pt"),
    (152, "152pt"),
    (167, "167pt"),
    (180, "180pt"),
    (1024, "1024pt")
]

def create_png_from_svg(svg_path, png_path, size):
    """Convert SVG to PNG at specified size using built-in tools"""
    try:
        # Try using qlmanage (built into macOS)
        cmd = [
            'qlmanage', 
            '-t', 
            '-s', str(size),
            '-o', str(png_path.parent),
            str(svg_path)
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # qlmanage creates files with .png.png extension, rename it
            temp_file = png_path.parent / f"{svg_path.stem}.png.png"
            if temp_file.exists():
                temp_file.rename(png_path)
                return True
        
        print(f"qlmanage failed for {size}px, trying alternative method...")
        
        # Alternative: use built-in rsvg-convert if available
        cmd = [
            'rsvg-convert', 
            '-w', str(size),
            '-h', str(size), 
            '-o', str(png_path),
            str(svg_path)
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0
        
    except Exception as e:
        print(f"Error creating {size}px icon: {e}")
        return False

def main():
    # Paths
    base_dir = Path(__file__).parent
    svg_file = base_dir / "app-icon-1024.svg"
    icons_dir = base_dir / "AppIcons"
    
    # Create icons directory
    icons_dir.mkdir(exist_ok=True)
    
    print("🔥 Creating Obsidian Notes App Icons...")
    print(f"Source SVG: {svg_file}")
    print(f"Output directory: {icons_dir}")
    
    if not svg_file.exists():
        print(f"❌ SVG file not found: {svg_file}")
        return
    
    success_count = 0
    
    for size, name in ICON_SIZES:
        png_file = icons_dir / f"icon-{size}.png"
        
        print(f"Creating {size}x{size} icon...", end=" ")
        
        if create_png_from_svg(svg_file, png_file, size):
            print("✅")
            success_count += 1
        else:
            print("❌")
    
    print(f"\n🎉 Created {success_count}/{len(ICON_SIZES)} app icons!")
    
    if success_count > 0:
        print(f"\n📁 Icons saved to: {icons_dir}")
        print("\n📱 Next steps:")
        print("1. Open Xcode project")
        print("2. Go to Assets.xcassets → AppIcon")
        print("3. Drag and drop the appropriate sized icons")
        print("4. Sizes needed:")
        for size, name in ICON_SIZES:
            print(f"   - {size}x{size} for {name}")
    
    # Create a simple HTML preview
    html_content = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <title>Obsidian Notes - App Icons Preview</title>
        <style>
            body {{ font-family: -apple-system, BlinkMacSystemFont, sans-serif; padding: 20px; background: #1a1a2e; color: white; }}
            .icon {{ margin: 10px; display: inline-block; text-align: center; }}
            .icon img {{ border-radius: 20%; box-shadow: 0 4px 12px rgba(0,0,0,0.3); }}
            .icon p {{ margin: 5px 0; font-size: 12px; }}
        </style>
    </head>
    <body>
        <h1>🔮 Obsidian Notes - App Icons</h1>
        <div>
    """
    
    for size, name in ICON_SIZES:
        html_content += f"""
            <div class="icon">
                <img src="AppIcons/icon-{size}.png" width="{min(size, 120)}" height="{min(size, 120)}" alt="{size}px icon">
                <p>{size}x{size}<br>{name}</p>
            </div>
        """
    
    html_content += """
        </div>
    </body>
    </html>
    """
    
    html_file = base_dir / "app-icons-preview.html"
    html_file.write_text(html_content)
    print(f"\n🌐 Preview HTML created: {html_file}")

if __name__ == "__main__":
    main()