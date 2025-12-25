# iOS Build CI/CD Setup Guide

This guide explains how to set up GitHub Actions for automated iOS builds.

## Current Status

The GitHub Actions workflow has been created at `.github/workflows/ios-build.yml` and will:
- ✅ Run on every push to `main` branch
- ✅ Run on pull requests
- ✅ Can be manually triggered
- ✅ Build iOS app without code signing (for testing workflow)
- ⚠️ Requires additional setup for signed IPA builds

## What Works Now

Without any additional setup, the workflow will:
1. Check out your code
2. Set up Flutter 3.35.4
3. Install dependencies
4. Run Flutter analyzer
5. Run tests
6. Install CocoaPods
7. Build iOS app (unsigned)

## Code Signing Setup (Required for TestFlight/App Store)

To build signed IPA files for distribution, you need to set up code signing. Here are your options:

### Option 1: Manual Code Signing (Simpler)

1. **Get an Apple Developer Account**
   - Enroll at https://developer.apple.com ($99/year)

2. **Create Certificates and Provisioning Profiles**
   - Go to https://developer.apple.com/account
   - Create a Distribution Certificate
   - Create an App ID for your app
   - Create a Distribution Provisioning Profile

3. **Export Certificates**
   - Open Keychain Access on Mac
   - Export your certificate as .p12 file with a password
   - Convert to base64: `base64 -i certificate.p12 | pbcopy`

4. **Add GitHub Secrets**
   Go to your GitHub repository → Settings → Secrets and variables → Actions

   Add these secrets:
   - `IOS_CERTIFICATE_BASE64` - Base64 encoded .p12 certificate
   - `IOS_CERTIFICATE_PASSWORD` - Password for the .p12 file
   - `IOS_PROVISIONING_PROFILE_BASE64` - Base64 encoded provisioning profile
   - `KEYCHAIN_PASSWORD` - Any random password for temporary keychain

### Option 2: Fastlane Match (Recommended for Teams)

1. **Install Fastlane**
   ```bash
   cd ios
   bundle init
   bundle add fastlane
   ```

2. **Setup Match**
   ```bash
   bundle exec fastlane match init
   ```
   Choose to store certificates in a private git repository

3. **Generate Certificates**
   ```bash
   bundle exec fastlane match appstore
   ```

4. **Add GitHub Secrets**
   - `MATCH_PASSWORD` - Encryption password for certificates
   - `MATCH_GIT_BASIC_AUTHORIZATION` - Base64 encoded git credentials
   - `FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD` - App-specific password from Apple ID

### Option 3: Codemagic (Easiest)

If you prefer not to deal with code signing complexity:
1. Sign up at https://codemagic.io
2. Connect your repository
3. Use their UI to upload certificates
4. They handle the code signing automatically

## Update Workflow for Code Signing

Once you have certificates set up, update `.github/workflows/ios-build.yml`:

### For Manual Code Signing:

Replace the "Build iOS IPA" step with:
```yaml
- name: Import Certificate
  env:
    CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
    CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
    KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
  run: |
    echo $CERTIFICATE_BASE64 | base64 --decode > certificate.p12
    security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
    security import certificate.p12 -k build.keychain -P "$CERTIFICATE_PASSWORD" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain

- name: Build IPA
  run: flutter build ipa --release

- name: Upload IPA
  uses: actions/upload-artifact@v4
  with:
    name: ios-ipa
    path: build/ios/ipa/*.ipa
```

## Testing the Workflow

1. **Push to trigger the workflow**
   ```bash
   git add .github/
   git commit -m "Add iOS CI/CD workflow"
   git push origin main
   ```

2. **Monitor the build**
   - Go to your GitHub repository
   - Click on "Actions" tab
   - Watch your workflow run

3. **Download artifacts**
   - After the build completes
   - Click on the workflow run
   - Download the build artifacts

## Troubleshooting

### Common Issues

1. **CocoaPods errors**
   - Make sure your `ios/Podfile` is up to date
   - Try running `pod repo update` locally

2. **Code signing errors**
   - Verify all secrets are properly set
   - Check certificate expiration dates
   - Ensure provisioning profile matches bundle ID

3. **Build fails on dependencies**
   - Check `pubspec.yaml` for platform-specific dependencies
   - Some packages may not support iOS

## Next Steps

1. ✅ Workflow is created and ready to use
2. ⏳ Set up code signing (optional for now)
3. ⏳ Test the workflow by pushing code
4. ⏳ Configure TestFlight upload (requires code signing)
5. ⏳ Configure App Store deployment (requires code signing)

## Resources

- [Flutter iOS Deployment](https://docs.flutter.dev/deployment/ios)
- [GitHub Actions for Flutter](https://docs.flutter.dev/deployment/cd#github-actions)
- [Fastlane Match](https://docs.fastlane.tools/actions/match/)
- [Apple Developer Portal](https://developer.apple.com/account)

## Support

For issues with:
- GitHub Actions: Check Actions tab for error logs
- Code signing: Refer to Apple Developer documentation
- Flutter build: Run `flutter doctor -v` and check for issues
