#!/bin/bash
#
# update_scanbot_sdk_version.sh
#
# Updates the ScanbotSDK SPM dependency version across all Xcode projects
# in this repository.
#
# Usage:
#   ./update_scanbot_sdk_version.sh <new_version>
#
# Examples:
#   ./update_scanbot_sdk_version.sh 8.1.0
#   ./update_scanbot_sdk_version.sh 8.0.5-RC1
#

NEW_VERSION="$1"

if [ -z "$NEW_VERSION" ]; then
    echo "❌ Error: No version specified."
    echo ""
    echo "Usage: $0 <new_version>"
    echo "Examples: $0 8.1.0  or  $0 8.0.5-RC1"
    exit 1
fi

# Validate version format (e.g., 8.0.4, 10.1.0, 8.0.5-RC1)
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-RC[0-9]+)?$ ]]; then
    echo "❌ Error: Invalid version format '$NEW_VERSION'. Expected format: X.Y.Z or X.Y.Z-RCN (e.g., 8.1.0 or 8.0.5-RC1)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# All project directories
PROJECTS=(
    "ClassicComponent/ClassicComponentsExample.xcodeproj"
    "DataCaptureRTUUI/DataCaptureRTUUIExample.xcodeproj"
    "DocumentRTUUI/DocumentScannerRTUUIExample.xcodeproj"
    "SwiftUI/SwiftUIComponentsExample.xcodeproj"
)

echo "🔄 Updating ScanbotSDK SPM version to $NEW_VERSION across all projects..."
echo ""

UPDATED_COUNT=0

for PROJECT in "${PROJECTS[@]}"; do
    PBXPROJ="$SCRIPT_DIR/$PROJECT/project.pbxproj"
    RESOLVED="$SCRIPT_DIR/$PROJECT/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
    PROJECT_NAME=$(basename "$PROJECT" .xcodeproj)

    echo "📦 $PROJECT_NAME"

    # --- Update project.pbxproj ---
    if [ -f "$PBXPROJ" ]; then
        # Extract current version from the scanbot package reference
        CURRENT_VERSION=$(python3 -c "
import re, sys
with open('$PBXPROJ', 'r') as f:
    content = f.read()
pattern = r'XCRemoteSwiftPackageReference \"scanbot-sdk-ios-spm\"[^}]*?version = \"?([^\";]+)\"?;'
match = re.search(pattern, content, flags=re.DOTALL)
if match:
    print(match.group(1))
else:
    print('NOT_FOUND')
")

        if [ "$CURRENT_VERSION" = "NOT_FOUND" ]; then
            echo "   ⚠️  scanbot-sdk-ios-spm package reference not found in pbxproj"
        elif [ "$CURRENT_VERSION" = "$NEW_VERSION" ]; then
            echo "   ⏭️  Already at version $CURRENT_VERSION"
        else
            # Perform the replacement
            python3 -c "
import re
with open('$PBXPROJ', 'r') as f:
    content = f.read()
pattern = r'(XCRemoteSwiftPackageReference \"scanbot-sdk-ios-spm\"[^}]*?version = )\"?[^\";]+\"?;'
new_content = re.sub(pattern, r'\g<1>\"$NEW_VERSION\";', content, flags=re.DOTALL)
with open('$PBXPROJ', 'w') as f:
    f.write(new_content)
"
            echo "   ✅ pbxproj: $CURRENT_VERSION → $NEW_VERSION"
            UPDATED_COUNT=$((UPDATED_COUNT + 1))

            # Delete Package.resolved and re-resolve to regenerate it
            if [ -f "$RESOLVED" ]; then
                rm "$RESOLVED"
            fi
            echo "   📥 Resolving packages..."
            xcodebuild -resolvePackageDependencies -project "$SCRIPT_DIR/$PROJECT" -quiet 2>&1 | while read -r line; do echo "      $line"; done
            if [ -f "$RESOLVED" ]; then
                echo "   ✅ Package.resolved regenerated"
            else
                echo "   ⚠️  Package.resolved was not regenerated. Open the project in Xcode to resolve."
            fi
        fi
    else
        echo "   ⚠️  project.pbxproj not found"
    fi

    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $UPDATED_COUNT -gt 0 ]; then
    echo "✅ Done! Updated $UPDATED_COUNT project(s) to ScanbotSDK $NEW_VERSION"
else
    echo "ℹ️  All projects already at version $NEW_VERSION."
fi
echo ""
echo "Next steps:"
echo "  Open each project in Xcode to verify the update."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
