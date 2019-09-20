(async function () {
  // Need to patch app.views.Mobile.detect internals to force desktop mode.
  const original = window.matchMedia
  const patcher = function () {
    return { matches: false }
  }
  window.matchMedia = patcher

  const globalDefined = (attr) => {
    return new Promise(function (resolve, reject) {
      const checker = () => {
        if (Object.prototype.hasOwnProperty.call(window, attr)) {
          resolve(window[attr])
        } else {
          requestAnimationFrame(checker)
        }
      }
      requestAnimationFrame(checker)
    })
  }

  const app = await globalDefined('app')
  app.isMobile = () => false
  app.views.Mobile.detect = () => false

  window.matchMedia = original
  window.webkit.messageHandlers.vcBus.postMessage({ type: 'afterInit' })
}())
