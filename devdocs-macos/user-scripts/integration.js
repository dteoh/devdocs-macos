(async function () {
  // Force desktop mode.
  // TODO maybe this should be done in Cocoa?
  document.cookie = 'override-mobile-detect=false'

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

  await globalDefined('app')

  window.webkit.messageHandlers.vcBus.postMessage({ type: 'afterInit' })
}())
