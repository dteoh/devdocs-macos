(function() {
    // Need to patch app.views.Mobile.detect internals to force desktop mode.
    var original = window.matchMedia;
    var patcher = function() {
        return { matches: false };
    };
    window.matchMedia = patcher;

    var afterInit = function() {
        if (window.app && window.app.settings) {
            window.matchMedia = original;
            window.webkit.messageHandlers.vcBus.postMessage({ type: 'afterInit' });
        } else {
            requestAnimationFrame(afterInit);
        }
    };
    requestAnimationFrame(afterInit);
}());
