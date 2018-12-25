(function() {
    var observer = new MutationObserver(function(mutations) {
        console.log('mutation observer fired');
        window.webkit.messageHandlers.vcBus.postMessage({
            type: 'titleNotification',
            args: {
                title: $('head title').innerText,
            },
        });
        console.log('mutation observer ended');
    });

    var titleEl = document.querySelector('title');
    observer.observe(titleEl, {
        childList: true,
        characterData: true,
        subtree: true,
    });
    console.log('mutation observer registered');
}());
