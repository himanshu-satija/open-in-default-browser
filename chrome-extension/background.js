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
      const error = chrome.runtime.lastError.message;
      console.error('Native host error:', error);

      // Check if native host is not installed
      if (error.includes('host not found') || error.includes('not installed') || error.includes('Specified native messaging host not found')) {
        showNotification('error', 'Native host not installed',
          'Please install the companion app to use this extension.');
      } else {
        showNotification('error', 'Connection error', error);
      }
    }
  });

  // Send the URL to the native host
  port.postMessage({ url: url });
}

// Show notification to user
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
