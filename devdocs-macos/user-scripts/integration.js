(function() {
    var original = document.addEventListener;
    var patcher = function() {
        // Force desktop mode.
        if (arguments[0] === 'DOMContentLoaded') {
            app.views.Mobile.detect = function() {
                return false;
            };
            document.addEventListener = original;
        }
        original.apply(null, arguments);
    };
    document.addEventListener = patcher;

    var afterInit = function() {
        if (typeof app.settings === 'object') {
            window.webkit.messageHandlers.vcBus.postMessage({ type: 'afterInit' });
        } else {
            requestAnimationFrame(afterInit);
        }
    };
    requestAnimationFrame(afterInit);
}());
