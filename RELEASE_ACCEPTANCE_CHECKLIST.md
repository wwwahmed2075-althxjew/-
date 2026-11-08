# AWWAB release acceptance checklist

This file is the release gate. A successful APK build alone is not a release.

## Product identity and navigation
- [ ] Monochrome black/white visual system only.
- [ ] Real frosted-glass surfaces with blur, thin borders and subtle depth.
- [ ] Floating iOS-inspired bottom dock: Home, Azkar, Quran, Tasbeeh, More.
- [ ] Small, consistent iOS-inspired icons; every visible control has a verified action.
- [ ] More hub includes all agreed features and settings.

## Quran / Mushaf
- [x] Full Quran text available offline from an embedded dataset (Tanzil attribution retained).
- [x] Open surah and display ayat without an internet request.
- [x] Persist last-read position on device.
- [x] Change reading text size.
- [ ] Mushaf page layout and vertical/horizontal reading modes.
- [ ] Search ayat and surah names.
- [ ] Bookmarks list and restore last-read position from home.
- [ ] Translation/tafsir only from identified, licensed sources.
- [ ] Audio playback/download and reciter selection (do not show fake controls).

## Prayer and worship
- [x] Local prayer-time calculation using Egyptian General Authority of Survey parameters.
- [x] City selector with Egyptian city coordinates; no internet needed for calculation.
- [ ] User location permission and verified location selection.
- [ ] Prayer countdown and daily widget on home.
- [ ] Qibla compass with device sensor permission and calibration.
- [ ] Real scheduled prayer notifications / adhan with permission handling and tested sound choices.
- [ ] Islamic/Hijri calendar.

## Agreed More sections
- [ ] Ruqyah: Ayat al-Kursi, Al-Ikhlas, Al-Falaq, An-Nas, with source-verified text.
- [ ] Virtues of Quran and dhikr, with referenced authentic narrations.
- [ ] Qiyam al-Layl and Duha guidance.
- [ ] Reminders: Monday/Thursday fasting and sending blessings upon the Prophet.
- [ ] Multiple adhan sounds, licensed/available offline, selectable and previewable.
- [ ] Additional worship tools and daily wird.

## Settings and accessibility
- [ ] Working Arabic / English / French localization.
- [ ] Working font family selection and font size, persisted after restart.
- [ ] Working appearance setting, while keeping the approved black/white glass default.
- [ ] Notification permissions and controls.
- [x] Tasbeeh and azkar progress persistence.

## Release QA
- [ ] Flutter analyze with no errors.
- [ ] Automated tests for Quran offline loading, prayer calculations, navigation and persistence.
- [ ] Verify all buttons, icons, routes, empty/error states on Android.
- [ ] Install on a clean Android device and test offline mode (airplane mode).
- [ ] Verify package ID, version code and signing/reinstall behavior.
- [ ] Inspect APK size and confirm ABI compatibility.
- [ ] Only then publish a release APK and release notes.

## Current implementation notes
- The previous Quran reader used an HTTP API and could not work offline. It has been replaced with the embedded quran_data_dart dataset.
- The previous prayer card was a placeholder. It now opens a local calculation page using the Egyptian method, with selectable Egyptian cities.
- Items not checked above must not be advertised as complete or shown as non-functional buttons.