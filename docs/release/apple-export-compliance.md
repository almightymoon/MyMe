# Apple Export Compliance

## Info.plist setting

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Location: `apps/mobile/ios/Runner/Info.plist`.

## Engineering assumption (not legal advice)

MeMy v1 is intended to use only:

- HTTPS for optional outbound links (`url_launcher`, Help/Legal markdown links)
- Platform-provided storage and OS cryptography for local SQLite / SharedPreferences

There is **no** custom encryption library, VPN, or proprietary cipher implementation in the app dependencies listed for v1.

## Owner / legal action required

1. Confirm with counsel whether MeMy qualifies for the standard App Store Connect “uses encryption only as exempt / standard” answers given the actual networking and storage stack.
2. If counsel disagrees, set `ITSAppUsesNonExemptEncryption` to `true` and complete the annual self-classification / ERN process as required.
3. Answer App Store Connect export-compliance questions consistently with that legal determination — do not rely on this doc alone.

**Status:** Engineering draft assumption only. **Not confirmed by legal.**
