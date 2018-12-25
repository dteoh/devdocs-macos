(function() {
    var original = document.addEventListener;
    var patcher = function() {
        if (arguments[0] === 'DOMContentLoaded') {
            app.views.Mobile.detect = function() {
                return false;
            };
        }
        original.apply(null, arguments);
    }

    document.addEventListener = patcher;

    var init = function() {
        original.removeEventListener('DOMContentLoaded', init, false);
        document.addEventListener = original;
    }
    original.addEventListener('DOMContentLoaded', init, false);
}());
