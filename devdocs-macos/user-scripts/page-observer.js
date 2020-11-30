/* global $ */
(function () {
  const findTitleComponents = function () {
    const { entry } = window.app.document.content.view
    if (!entry) {
      return {}
    }
    return {
      doc: entry.doc.fullName,
      topic: entry.name
    }
  }

  const observer = new MutationObserver((mutations) => {
    window.webkit.messageHandlers.vcBus.postMessage({
      type: 'titleNotification',
      args: {
        title: $('head title').innerText,
        ...findTitleComponents()
      }
    })
    window.webkit.messageHandlers.vcBus.postMessage({
      type: 'locationNotification',
      args: {
        location: document.location.toString()
      }
    })
  })

  const titleEl = document.querySelector('title')
  observer.observe(titleEl, {
    childList: true,
    characterData: true,
    subtree: true
  })
}())
