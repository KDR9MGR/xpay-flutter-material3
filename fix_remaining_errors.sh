#!/bin/bash

# Fix Remaining AppLogger Errors
set -e

echo "🔧 Fixing remaining AppLogger errors..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Fix specific AppLogger calls with 3 arguments (message, tag, error)
print_info "Fixing AppLogger calls with 3 arguments..."

# Fix crash_prevention.dart
if [[ -f "lib/utils/crash_prevention.dart" ]]; then
    sed -i '' "s/AppLogger\.error(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.error(\1, tag: \2, error: \3)/g" "lib/utils/crash_prevention.dart"
    print_status "Fixed crash_prevention.dart"
fi

# Fix memory_optimizer.dart
if [[ -f "lib/utils/memory_optimizer.dart" ]]; then
    sed -i '' "s/AppLogger\.error(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.error(\1, tag: \2, error: \3)/g" "lib/utils/memory_optimizer.dart"
    sed -i '' "s/AppLogger\.warning(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.warning(\1, tag: \2, error: \3)/g" "lib/utils/memory_optimizer.dart"
    print_status "Fixed memory_optimizer.dart"
fi

# Fix wallet_view_model.dart
if [[ -f "lib/views/auth/wallet_view_model.dart" ]]; then
    sed -i '' "s/AppLogger\.error(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.error(\1, tag: \2, error: \3)/g" "lib/views/auth/wallet_view_model.dart"
    sed -i '' "s/AppLogger\.info(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.info(\1, tag: \2)/g" "lib/views/auth/wallet_view_model.dart"
    print_status "Fixed wallet_view_model.dart"
fi

# Fix video_background_widget.dart
if [[ -f "lib/widgets/video_background_widget.dart" ]]; then
    sed -i '' "s/AppLogger\.error(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.error(\1, tag: \2, error: \3)/g" "lib/widgets/video_background_widget.dart"
    sed -i '' "s/AppLogger\.warning(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.warning(\1, tag: \2, error: \3)/g" "lib/widgets/video_background_widget.dart"
    sed -i '' "s/AppLogger\.info(\([^,]*\), \([^,]*\), \([^)]*\))/AppLogger.info(\1, tag: \2)/g" "lib/widgets/video_background_widget.dart"
    print_status "Fixed video_background_widget.dart"
fi

# Fix any remaining 2-argument calls that weren't caught
print_info "Fixing remaining 2-argument AppLogger calls..."
find lib -name "*.dart" -type f -exec sed -i '' "s/AppLogger\.info('\([^']*\)', '\([^']*\)')/AppLogger.info('\1', tag: '\2')/g" {} \;
find lib -name "*.dart" -type f -exec sed -i '' "s/AppLogger\.error('\([^']*\)', '\([^']*\)')/AppLogger.error('\1', tag: '\2')/g" {} \;
find lib -name "*.dart" -type f -exec sed -i '' "s/AppLogger\.warning('\([^']*\)', '\([^']*\)')/AppLogger.warning('\1', tag: '\2')/g" {} \;
find lib -name "*.dart" -type f -exec sed -i '' "s/AppLogger\.debug('\([^']*\)', '\([^']*\)')/AppLogger.debug('\1', tag: '\2')/g" {} \;

# Fix double quote versions
find lib -name "*.dart" -type f -exec sed -i '' 's/AppLogger\.info("\([^"]*\)", "\([^"]*\)")/AppLogger.info("\1", tag: "\2")/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/AppLogger\.error("\([^"]*\)", "\([^"]*\)")/AppLogger.error("\1", tag: "\2")/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/AppLogger\.warning("\([^"]*\)", "\([^"]*\)")/AppLogger.warning("\1", tag: "\2")/g' {} \;
find lib -name "*.dart" -type f -exec sed -i '' 's/AppLogger\.debug("\([^"]*\)", "\([^"]*\)")/AppLogger.debug("\1", tag: "\2")/g' {} \;

print_status "Fixed remaining AppLogger calls"

# Fix double quotes to single quotes in specific files
print_info "Converting double quotes to single quotes..."
files_to_fix=(
    "lib/views/setting/change_language_screen.dart"
    "lib/utils/strings.dart"
    "lib/utils/language/arabic_language.dart"
    "lib/utils/language/spanish_language.dart"
    "lib/utils/language/english_language.dart"
)

for file in "${files_to_fix[@]}"; do
    if [[ -f "$file" ]]; then
        # Convert simple double quotes to single quotes
        sed -i '' "s/\"\([^\"]*\)\"/'\'\1\'/g" "$file"
        print_status "Fixed quotes in: $file"
    fi
done

# Run final analysis
print_info "Running final analysis..."
flutter analyze --write=analysis_final_fixed.txt 2>/dev/null || true

if [[ -f "analysis_final_fixed.txt" ]]; then
    remaining_issues=$(wc -l < analysis_final_fixed.txt)
    print_status "Final analysis complete. Remaining issues: $remaining_issues"
    
    if [[ $remaining_issues -lt 10 ]]; then
        print_status "🎉 Excellent! Almost all errors fixed!"
    elif [[ $remaining_issues -lt 50 ]]; then
        print_status "✨ Great progress! Most errors fixed!"
    else
        echo "⚠️  Some issues remain. Check analysis_final_fixed.txt for details."
    fi
fi

print_status "🎉 Remaining error fixes completed!"
echo "Next: Test compilation with 'flutter build ios --debug --no-codesign'"