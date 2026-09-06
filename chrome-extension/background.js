// Native messaging host name (must match the host manifest)
const NATIVE_HOST_NAME = 'com.openindefaultbrowser.host';

// Stable ID for the "not installed" notification so we can respond to clicks on it
const INSTALL_NOTIF_ID = 'native-host-not-installed';
const RELEASES_URL = 'https://github.com/himanshu-satija/open-in-default-browser/releases';

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

// Open GitHub releases page when the user clicks the notification body or its button
chrome.notifications.onClicked.addListener((notificationId) => {
  if (notificationId === INSTALL_NOTIF_ID) {
    chrome.tabs.create({ url: RELEASES_URL });
    chrome.notifications.clear(INSTALL_NOTIF_ID);
  }
});

chrome.notifications.onButtonClicked.addListener((notificationId, buttonIndex) => {
  if (notificationId === INSTALL_NOTIF_ID) {
    chrome.tabs.create({ url: RELEASES_URL });
    chrome.notifications.clear(INSTALL_NOTIF_ID);
  }
});

// Send URL to native messaging host
function openInDefaultBrowser(url) {
  const port = chrome.runtime.connectNative(NATIVE_HOST_NAME);
  let responseReceived = false;

  // Set timeout for unresponsive native host
  const timeoutId = setTimeout(() => {
    if (!responseReceived) {
      showNotification('error', 'Request timeout',
        'The native host did not respond. Please check if it is installed correctly.');
      port.disconnect();
    }
  }, 5000); // 5 second timeout

  port.onMessage.addListener((response) => {
    responseReceived = true;
    clearTimeout(timeoutId);
    console.log('Received from native host:', response);

    if (!response.success) {
      showNotification('error', 'Failed to open link', response.error || 'Unknown error occurred');
    }
  });

  port.onDisconnect.addListener(() => {
    clearTimeout(timeoutId);
    if (chrome.runtime.lastError && !responseReceived) {
      const error = chrome.runtime.lastError.message || '';
      console.error('Native host error:', error);

      // "Forbidden" = host binary not installed or extension ID not in allowed_origins
      // "Not found"  = manifest JSON missing from NativeMessagingHosts directory
      const isNotInstalled =
        error.includes('forbidden') ||
        error.includes('not found') ||
        error.includes('not installed') ||
        error.includes('Specified native messaging host not found');

      if (isNotInstalled) {
        chrome.notifications.create(INSTALL_NOTIF_ID, {
          type: 'basic',
          iconUrl: 'icon48.png',
          title: 'Native host not installed',
          message: 'Click here to download the installer from GitHub.',
          priority: 2,
          requireInteraction: true,
          buttons: [{ title: 'Download Installer' }]
        });
      } else {
        showNotification('error', 'Could not open link', error);
      }
    }
  });

  // Send the URL to the native host
  port.postMessage({ url: url });
}

// Show a generic notification
function showNotification(type, title, message = '') {
  const notificationOptions = {
    type: 'basic',
    iconUrl: 'icon48.png',
    title: title,
    message: message,
    priority: type === 'error' ? 2 : 1,
    requireInteraction: type === 'error' // Errors stay until dismissed
  };

  chrome.notifications.create('', notificationOptions);
}
