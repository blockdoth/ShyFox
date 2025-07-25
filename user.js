// userchrome.css usercontent.css activate
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// disable new sidebar
user_pref("sidebar.revamp", false);

// Fill SVG Color
user_pref("svg.context-properties.content.enabled", true);

// CSS's `:has()` selector 
user_pref("layout.css.has-selector.enabled", true);

// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
user_pref("browser.urlbar.unitConversion.enabled", true);

// Trim  URL
user_pref("browser.urlbar.trimHttps", true);
user_pref("browser.urlbar.trimURLs", true);

// GTK rounded corners
user_pref("widget.gtk.rounded-bottom-corners.enabled", true);

// Who is bogus? (fixes Sidebery tab dragging on Linux)
user_pref("widget.gtk.ignore-bogus-leave-notify", 1);
user_pref("shyfox.disable.floating.search", true);

// Dark mode
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("browser.in-content.dark-mode", true);
user_pref("layout.css.prefers-color-scheme.content-override", 2);