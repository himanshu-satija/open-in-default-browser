// Native messaging host name (must match the host manifest)
const NATIVE_HOST_NAME = 'com.openindefaultbrowser.host';

// Create context menu item when extension is installed
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: 'openInDefaultBrowser',
    title: 'Open in default browser',
    contexts: ['link']
  });
});

// Handle context menu clicks
chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId === 'openInDefaultBrowser' && info.linkUrl) {
    openInDefaultBrowser(info.linkUrl);
  }
});

// Send URL to native messaging host
function openInDefaultBrowser(url) {
  const port = chrome.runtime.connectNative(NATIVE_HOST_NAME);

  port.onMessage.addListener((response) => {
    console.log('Received from native host:', response);
  });

  port.onDisconnect.addListener(() => {
    if (chrome.runtime.lastError) {
      console.error('Native host error:', chrome.runtime.lastError.message);
    }
  });

  // Send the URL to the native host
  port.postMessage({ url: url });
}
