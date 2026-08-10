# Health Disclaimer

**Status:** Draft  
**Version:** 0.1.0  
**Effective date:** 2026-08-10  
**Product:** MeMy by MoonTech

MeMy’s Health features display wellness summaries derived from your device health platforms (HealthKit on iOS, Health Connect on Android) when you connect them.

## Not medical advice

MeMy is **not** a medical device and does **not** provide diagnosis, treatment, or clinical decision support. Information shown is for personal awareness only. Always consult a qualified clinician for health concerns.

## Data handling (this build)

- MeMy reads selected metrics with your permission (read-only).
- Platform Health remains the source of truth.
- MeMy stores connection/permission configuration locally.
- Daily summaries are held in memory for the session and cleared on disconnect.
- Health sample values are **not** uploaded to MeMy API, analytics, ads, or AI providers in this build.
- Disconnecting clears MeMy’s Health configuration and in-memory summaries; it does **not** delete data from HealthKit / Health Connect.

## Accuracy

Platform availability, permissions, and sensor quality affect what MeMy can show. Missing or partial permissions may produce incomplete summaries without implying a health condition.
