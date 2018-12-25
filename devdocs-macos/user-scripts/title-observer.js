(function() {
    var observer = new MutationObserver(function(mutations) {
        window.webkit.messageHandlers.vcBus.postMessage({
            type: 'titleNotification',
            args: {
                title: $('head title').innerText,
            },
        });
    });

    var titleEl = document.querySelector('title');
    observer.observe(titleEl, {
        childList: true,
        characterData: true,
        subtree: true,
    });
}());
