(function () {
  // Need to patch app.views.Mobile.detect internals to force desktop mode.
  const original = window.matchMedia
  const patcher = function () {
    return { matches: false }
  }
  window.matchMedia = patcher

  const afterInit = function () {
    if (window.app && window.app.settings) {
      window.matchMedia = original
      window.webkit.messageHandlers.vcBus.postMessage({ type: 'afterInit' })
    } else {
      requestAnimationFrame(afterInit)
    }
  }
  requestAnimationFrame(afterInit)
}())
