var useDarkMode = function(enable) {
    var inDarkMode = !!app.settings.get('dark');
    if (enable && inDarkMode) {
        return;
    }
    if (!enable && !inDarkMode) {
        return;
    }
    var sp = new app.views.SettingsPage()
    sp.toggleDark(enable);
};

