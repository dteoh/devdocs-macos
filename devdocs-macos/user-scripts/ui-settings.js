/* global app */

window.useNativeScrollbars = function (enable) {
  requestAnimationFrame(() => {
    const sp = new app.views.SettingsPage()
    sp.toggleLayout('_native-scrollbars', enable)
  })
}

window.overridePreferencesExport = function () {
  requestAnimationFrame(() => {
    app.document.content.settingsPage.export = () => {
      const preferences = JSON.stringify(app.settings.export())
      window.webkit.messageHandlers.vcBus.postMessage({
        type: 'exportPreferences',
        args: {
          preferences
        }
      })
    }
  })
}
