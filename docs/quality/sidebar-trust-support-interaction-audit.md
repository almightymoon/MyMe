# Sidebar / trust / support interaction audit

**Updated:** 2026-08-10  
**Scope:** Drawer, Privacy, Export, Deletion, Security, Help, Legal, About.

| Screen | Label | Action | Status | Tests |
|--------|-------|--------|--------|-------|
| Drawer | View Profile | → `/profile` | wired | drawer widget |
| Drawer | Today/Plan/Coach | shell tabs | wired | drawer widget |
| Drawer | Life area modules | push routes | wired | drawer widget |
| Drawer | Connected Apps | → connections | wired | |
| Drawer | Notifications | → planned screen | wired | |
| Drawer | Appearance | → accessibility | wired | |
| Drawer | Privacy & Data | → `/privacy` | wired | |
| Drawer | Security | → `/security` | wired | |
| Drawer | Help & Support | → `/support` | wired | drawer widget |
| Drawer | Legal | → `/legal` | wired | |
| Drawer | About | → `/about` | wired | |
| Drawer | Log Out | confirm → sign-in | wired | drawer widget |
| Privacy | Export | → export | wired | privacy widget |
| Privacy | Delete | → deletion | wired | |
| Privacy | AI data use | → ai screen | wired | |
| Export | Generate / Share | JSON share | wired | export unit |
| Deletion | Module / global | coordinator | wired | deletion unit |
| Support | Search | local filter | wired | help widget |
| Support | Contact / Report / Feature | share/mailto | wired | report unit |
| Legal | Documents | markdown draft | wired | |
| About | Version / What’s New / Licenses | PackageInfo + LicensePage | wired | |
| Settings | Trust rows | real routes | wired | |
| Settings | Change Password | planned message | wired | |

No SnackBar-only Help/Notifications stubs remain in the drawer.
