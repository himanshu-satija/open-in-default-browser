# Publishing Checklist for Open in Default Browser v1.0.0

Use this checklist to ensure everything is ready before publishing.

## Pre-Build Checklist

- [ ] All code changes committed to git
- [ ] Version number is 1.0.0 in manifest.json
- [ ] GitHub repo is at: https://github.com/himanshu-satija/open-in-default-browser
- [ ] PRIVACY.md is up to date (Last Updated: January 2025)
- [ ] STORE_LISTING.md is complete with all permissions documented
- [ ] Icons are present (icon48.png, icon128.png)

## Build Checklist

Run the build script:
```bash
./build-release.sh
```

Verify files created:
- [ ] `open-in-default-browser-extension.zip` exists
- [ ] `companion-app/build/OpenInDefaultBrowser-v1.0.0.dmg` exists

## Testing Checklist

### Test Extension
- [ ] Load extension from ZIP in Chrome (chrome://extensions/ → Developer mode → Load unpacked)
- [ ] Verify Extension ID appears
- [ ] Test right-click menu appears on links
- [ ] Test with native host NOT installed (should show error notification)
- [ ] Test with native host installed (should open in default browser silently)

### Test Companion App DMG
- [ ] Open DMG file
- [ ] Drag app to Applications
- [ ] Launch app from Applications
- [ ] Verify menu bar icon appears
- [ ] Click "Install" button
- [ ] Verify shows "✓ Installed" status
- [ ] Test extension works after installation
- [ ] Click "Uninstall" button
- [ ] Verify extension stops working
- [ ] Reinstall and verify it works again

## Assets Checklist

### Required for Chrome Web Store
- [ ] **Small Tile** (440x280): Promotional banner image created
- [ ] **Screenshot 1**: Context menu showing "Open in default browser" option
- [ ] **Screenshot 2** (optional): Link opening in different browser

### Optional (Recommended)
- [ ] **Marquee** (1400x560): Large promotional image for featured placement

## Chrome Web Store Publishing

1. **Go to Developer Dashboard**
   - [ ] Visit: https://chrome.google.com/webstore/devconsole
   - [ ] Sign in with Google account (himanshu-satija)
   - [ ] Verify developer registration is active ($5 fee paid)

2. **Create New Item**
   - [ ] Click "New Item"
   - [ ] Upload `open-in-default-browser-extension.zip`

3. **Store Listing Tab**
   - [ ] Copy detailed description from STORE_LISTING.md
   - [ ] Set category to "Productivity"
   - [ ] Set language to "English"
   - [ ] Upload small tile image (440x280)
   - [ ] Upload at least 1 screenshot
   - [ ] (Optional) Upload marquee image (1400x560)

4. **Privacy Tab**
   - [ ] Set privacy policy URL to:
         `https://raw.githubusercontent.com/himanshu-satija/open-in-default-browser/main/PRIVACY.md`
   - [ ] Verify the URL loads correctly in a browser

5. **Permissions Tab**
   - [ ] Review permissions: contextMenus, nativeMessaging, notifications
   - [ ] Add justification from STORE_LISTING.md (lines 80-83)

6. **Submit for Review**
   - [ ] Review all information one final time
   - [ ] Click "Submit for review"
   - [ ] Note the submission date/time: _________________

## GitHub Release

1. **Push Final Code**
   ```bash
   git add .
   git commit -m "Release v1.0.0"
   git tag v1.0.0
   git push origin main
   git push origin v1.0.0
   ```
   - [ ] Code pushed to main branch
   - [ ] Tag v1.0.0 created and pushed

2. **Create Release**
   - [ ] Go to: https://github.com/himanshu-satija/open-in-default-browser/releases
   - [ ] Click "Create a new release"
   - [ ] Select tag: v1.0.0
   - [ ] Release title: "Open in Default Browser v1.0.0"
   - [ ] Copy description from PACKAGING.md (lines 105-131)
   - [ ] Upload `OpenInDefaultBrowser-v1.0.0.dmg`
   - [ ] Click "Publish release"

3. **Verify Release**
   - [ ] Release is visible at releases page
   - [ ] DMG file is downloadable
   - [ ] Download link works:
         `https://github.com/himanshu-satija/open-in-default-browser/releases/download/v1.0.0/OpenInDefaultBrowser-v1.0.0.dmg`

## Post-Publication (After Chrome Web Store Approval)

Wait for Chrome Web Store review (1-3 business days):
- [ ] Received approval email from Chrome Web Store
- [ ] Extension is live on Chrome Web Store
- [ ] Copy Chrome Web Store URL: _________________________________

Update README.md:
- [ ] Add Chrome Web Store badge/link
- [ ] Update installation instructions with store link
- [ ] Commit and push changes

## Marketing (Optional)

- [ ] Tweet about the release
- [ ] Post on relevant subreddits (r/chrome, r/macapps)
- [ ] Share on ProductHunt
- [ ] Write a blog post

## Monitoring

After release, monitor:
- [ ] GitHub Issues for bug reports
- [ ] Chrome Web Store reviews
- [ ] GitHub Stars and forks

## Notes

### Important URLs
- Chrome Web Store Dashboard: https://chrome.google.com/webstore/devconsole
- GitHub Repo: https://github.com/himanshu-satija/open-in-default-browser
- Privacy Policy: https://raw.githubusercontent.com/himanshu-satija/open-in-default-browser/main/PRIVACY.md

### Timeline
- **Build Date**: _________________
- **Submitted to Chrome Web Store**: _________________
- **GitHub Release Published**: _________________
- **Chrome Web Store Approved**: _________________

### Extension Details (Fill after submission)
- **Extension ID**: _________________
- **Chrome Web Store URL**: _________________
- **Download Count**: Track weekly

## Troubleshooting

### If Chrome Web Store Rejects
Common reasons:
1. **Missing privacy policy**: Verify URL is accessible
2. **Permission justification unclear**: Update with more detail
3. **Promotional images wrong size**: Verify dimensions exactly
4. **Functionality not clear**: Add more detailed description

### If DMG Won't Open on User's Mac
- Verify it's signed (if applicable)
- Test on clean macOS install
- Check macOS version compatibility (10.15+)

### If Extension Can't Find Native Host
- Verify user installed companion app
- Check native host manifest is in correct location
- Verify extension ID matches in manifest

---

## Completion

When all checkboxes are complete:
- [ ] Extension is live on Chrome Web Store
- [ ] GitHub release is published
- [ ] README is updated with store link
- [ ] Monitoring is set up

**Release completed on**: _________________

**Extension published at**: _________________

🎉 Congratulations on publishing Open in Default Browser!
