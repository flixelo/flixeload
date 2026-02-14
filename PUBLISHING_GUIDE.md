# FlixeloAd SDK - Publishing Guide

## 📦 Publishing to pub.dev

### Prerequisites

1. **GitHub Repository** (REQUIRED)
   - Create: `https://github.com/flixelo/flixeload_sdk`
   - Must be public
   - Push all SDK code

2. **pub.dev Account**
   - Sign in at [pub.dev](https://pub.dev) with Google account
   - Verify email

3. **Documentation** (Recommended)
   - Set up docs.flixeload.com
   - API reference
   - Integration tutorials

---

## 🚀 Step-by-Step Publishing

### Step 1: Create GitHub Repository

```bash
# Navigate to SDK directory
cd /Applications/XAMPP/xamppfiles/htdocs/flixeload_sdk

# Initialize git
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial release of FlixeloAd SDK v1.0.0"

# Add remote (replace with your GitHub URL)
git remote add origin https://github.com/flixelo/flixeload_sdk.git

# Push to GitHub
git push -u origin main
```

### Step 2: Update pubspec.yaml

Ensure your `pubspec.yaml` has these fields:

```yaml
name: flixeload_sdk
description: FlixeloAd SDK - A Flutter plugin for integrating FlixeloAd mobile advertising network. Display banner, interstitial, native, and rewarded ads.
version: 1.0.0
homepage: https://flixeload.com
repository: https://github.com/flixelo/flixeload_sdk
issue_tracker: https://github.com/flixelo/flixeload_sdk/issues
documentation: https://docs.flixeload.com
```

### Step 3: Validate Package

```bash
cd /Applications/XAMPP/xamppfiles/htdocs/flixeload_sdk
flutter pub publish --dry-run
```

This will check for:
- ✅ Valid package structure
- ✅ Proper versioning
- ✅ Required files (README, LICENSE, CHANGELOG)
- ✅ Code analysis warnings

### Step 4: Publish to pub.dev

```bash
flutter pub publish
```

Follow the prompts:
1. Review the package contents
2. Confirm you want to publish
3. Authenticate with Google account
4. Wait for verification

---

## 📋 Required Files Checklist

- ✅ `pubspec.yaml` - Package metadata
- ✅ `README.md` - Usage documentation
- ✅ `CHANGELOG.md` - Version history
- ✅ `LICENSE` - License information
- ✅ `EXAMPLE.md` or `example/` - Example usage
- ✅ `lib/` - Source code
- ✅ `.gitignore` - Git ignore rules

---

## 🎯 After Publishing

### 1. Verify on pub.dev

Visit: `https://pub.dev/packages/flixeload_sdk`

Check:
- ✅ Package appears correctly
- ✅ Documentation renders properly
- ✅ Examples are clear
- ✅ Version is correct

### 2. Update Documentation

- Add pub.dev badge to README
- Update installation instructions
- Link to pub.dev from your website

### 3. Announce Release

- Blog post on flixeload.com
- Social media announcement
- Email to existing users
- Developer forums

---

## 📝 Version Updates

For future versions:

1. Update version in `pubspec.yaml`
2. Add entry to `CHANGELOG.md`
3. Commit and push to GitHub
4. Create GitHub release/tag
5. Run `flutter pub publish`

**Version Format:**
- Major: 1.0.0 → 2.0.0 (Breaking changes)
- Minor: 1.0.0 → 1.1.0 (New features)
- Patch: 1.0.0 → 1.0.1 (Bug fixes)

---

## 🔒 Alternative: Private Package

If you want to keep it private:

### Option 1: Private GitHub Repository

```yaml
dependencies:
  flixeload_sdk:
    git:
      url: https://github.com/flixelo/flixeload_sdk.git
      ref: v1.0.0
```

### Option 2: Private Package Repository

Use services like:
- **Dart Private Repository**: https://dart.dev/tools/pub/publishing
- **Cloudsmith**: https://cloudsmith.com
- **Artifact Registry**: (Google Cloud, AWS, etc.)

---

## 🎓 Best Practices

1. **Semantic Versioning**
   - Follow semver.org
   - Document breaking changes
   - Provide migration guides

2. **Documentation**
   - Clear API documentation
   - Working examples
   - Common use cases
   - Troubleshooting section

3. **Testing**
   - Unit tests for core functionality
   - Integration tests
   - Example app for testing

4. **Maintenance**
   - Respond to issues
   - Keep dependencies updated
   - Regular updates
   - Security patches

---

## 📞 Support

For publishing questions:
- **pub.dev Help**: https://dart.dev/tools/pub/publishing
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag with `flutter` and `pub`

---

## 🎉 Success Checklist

After publishing, your SDK will be available as:

```yaml
dependencies:
  flixeload_sdk: ^1.0.0
```

Users can install with:

```bash
flutter pub add flixeload_sdk
```

**Congratulations on publishing your SDK!** 🚀
