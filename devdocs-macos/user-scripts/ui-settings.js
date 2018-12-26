var useDarkMode = function(enable) {
    requestAnimationFrame(function() {
        var inDarkMode = !!app.settings.get('dark');
        if (enable && inDarkMode) {
            return;
        }
        if (!enable && !inDarkMode) {
            return;
        }
        var sp = new app.views.SettingsPage();
        sp.toggleDark(enable);
    });
};

var useNativeScrollbars = function(enable) {
    requestAnimationFrame(function() {
        var sp = new app.views.SettingsPage();
        sp.toggleLayout('_native-scrollbars', enable);
    });
};
