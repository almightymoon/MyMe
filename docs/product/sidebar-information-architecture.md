# Sidebar information architecture

MeMy uses **bottom navigation** for primary daily destinations and a
**right-side drawer** as the complete secondary navigation surface.

## Structure

### Account header
- Avatar / display name
- Demo Mode badge (production auth is not connected)
- Subtitle: profile email or “Demo account”
- View Profile → `/profile`

### Primary
- Today, Plan, AI Coach (shell tabs)

### Life areas
- Goals, Finance, Habits, Calendar, Health, Exercise, Wardrobe, Body

### Connections & preferences
- Connected Apps & Devices
- Notifications & Reminders (planned — honest screen)
- Appearance & Accessibility
- Settings

### Trust & help
- Privacy & Data
- Security
- Help & Support
- Legal
- About MeMy

### Footer
- App version / build from `package_info_plus`
- Demo Mode label

## Rules
- Current route / shell tab is highlighted.
- Drawer closes after navigation.
- Planned destinations still open truthful screens (no SnackBar stubs).
- Sign out confirms that local data is preserved.
- Nutrition remains available via Plan / Quick Add, not the drawer.
