(function () {
  const observer = new MutationObserver((mutations) => {
    window.webkit.messageHandlers.vcBus.postMessage({
      type: 'titleNotification',
      args: {
        title: $('head title').innerText
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
