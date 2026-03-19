# Ship Flip Seven - Research & Status

## What Was Done (Automated)

1. **Build uploaded to TestFlight** - Build 1.0.0 (build #6) uploaded via `fastlane beta`
2. **Screenshots uploaded** - 15 screenshots across 3 iPhone device sizes (17 Pro Max, 17 Pro, 17) uploaded via `fastlane upload_screenshots`
3. **Metadata configured via API** (`fastlane setup_metadata`):
   - Copyright: "2026 Dunnewold Labs"
   - Content rights: "Does not use third-party content"
   - Primary category: Games
   - Secondary category: Entertainment
   - Review contact info created (email, name, phone)
4. **Fastfile updated** with new lanes:
   - `setup_metadata` - sets copyright, categories, review contact via Spaceship API
   - `submit` - submits for App Store review

## Remaining Manual Step

### App Privacy Data Usage (Must be done in App Store Connect UI)

The App Store Connect API does not support the app privacy data usage endpoints via this version of fastlane/spaceship. This must be completed manually:

1. Go to [App Store Connect](https://appstoreconnect.apple.com) → Flip Seven → App Privacy
2. Start the privacy questionnaire
3. Select "No, we don't collect any data"
4. Save and publish the privacy answers

### After Privacy Is Set

Once the privacy data usage is published, you can either:
- Run `fastlane submit` to submit for review automatically
- Or submit manually via App Store Connect

### Review Contact Phone Number

The review contact was created with a placeholder phone number (+1 2025551234). You may want to update this to your real phone number in App Store Connect → App Information → App Review Information before submitting.
