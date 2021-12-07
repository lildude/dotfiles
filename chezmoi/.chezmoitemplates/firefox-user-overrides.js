
/*** My arkenfox user.js overrides - see https://github.com/arkenfox/user.js/wiki/3.3-Updater-Scripts ***/
user_pref("lildude.canary.in.a.coalmine", "overrides: started"); // canary for if I've made a mistake below

user_pref("browser.startup.page", 3); // 0102 - I want my previous session restored cos crashes
user_pref("browser.startup.homepage", "moz-extension://2e261119-0837-c54f-8aa1-c96aa41ee1f4/dashboard.html"); // 0103 - I use the Momentum extension

user_pref("browser.search.region", "GB"); // 0204 - [HIDDEN PREF] I like my language proper
user_pref("intl.accept_languages", "en-gb,en"); // 0210 - cos english

//user_pref("app.update.auto", true); // 0301 - I need this as Okta is a PITA if I don't have an up-to-date version

// JUST IN CASE: `extensions.formautofill.*` in 0517 all disabled in favour of 1Password

user_pref("network.dns.disableIPv6", false); // 0701 - I need IPv6
user_pref("network.proxy.socks_remote_dns", true); // 0702 - I might need to disable this when proxying through SSH.
user_pref("keyword.enabled", true); // 0801 - I like using the URL bar for easy searching
user_pref("browser.formfill.enable", true); // 0810 - I'm lazy
user_pref("security.ask_for_password", 0); // 0901 - I don't use Firefox's password manager, but in case it starts prompting, only the first time.
user_pref("security.password_lifetime", 30); // 0902 - As for 0901

user_pref("browser.cache.disk.enable", true); // 1001 - I use temp containers and a lot of tabs
user_pref("browser.sessionstore.privacy_level", 0); // 1003 - I'm not sure about this just yet so sticking with default

user_pref("security.mixed_content.block_display_content", false); // 1241 - Breaks a lot of sites

user_pref("media.gmp-widevinecdm.enabled", true); // 2021 - I likes Netflix
user_pref("media.gmp-widevinecdm.visible", true); // Gone? 1825 - I likes Netflix
user_pref("media.eme.enabled", true); // 2022 - I likes Netflix

user_pref("webgl.enable-webgl2", true); // Gone? 2010 - Strava and Mapbox playground needs WebGL
user_pref("webgl.min_capability_mode", false); // Gone? 2012 - Strava and Mapbox playground needs WebGL
user_pref("webgl.disable-fail-if-major-performance-caveat", false); // Gone? 2012 - Strava and Mapbox playground needs WebGL

user_pref("dom.serviceWorkers.enabled", true); // 2302 - It breaks websites
user_pref("dom.allow_cut_copy", true); // Gone? 2404 - I need this for GitHub's copy permalink func
user_pref("beacon.enabled", true); // 2602 - rewatch.com used for work vids needs this

user_pref("browser.download.useDownloadDir", true); // 2651 - I'm explicit in my setup so am happy to always go to downloads
user_pref("privacy.sanitize.sanitizeOnShutdown", false); // 2810 - Don't clear things everytime I shutdown
user_pref("privacy.clearOnShutdown.offlineApps", false); // 2811 - cos 2810 is false

user_pref("privacy.firstparty.isolate", false); // 4001 - Breaks a lot of stuff that uses cross-origin logins
// TODO: Changing these might fix some of the breakage of enabling above
// user_pref("privacy.firstparty.isolate.restrict_opener_access", false); // [DEFAULT: true]
// user_pref("privacy.firstparty.isolate.block_post_message", false);

user_pref("privacy.resistFingerprinting", false); // 4501 - this breaks Okta login
user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504
// 4600: These are enabled here because I've disabled 4501. Some of these might interfere with sites
user_pref("webgl.disabled", false); // 4520 - Strava and Mapbox playground needs WebGL

user_pref("browser.download.folderList", 1); // 5016 - Always download to downloads

user_pref("dom.event.clipboardevents.enabled", true); // 7013 - Needed for copy & paste on GDocs etc

// Personal settings unrelated to arkenfox/user.js
user_pref("extensions.pocket.enabled", true); // - I like Pocket
user_pref("security.enterprise_roots.enabled", true); // Trust keychain company certs - need for work
user_pref("security.osclientcerts.autoload", true);
user_pref("accessibility.typeaheadfind.flashBar", 0); // I don't want the toolbar to flash when a find matches

/*** Firefox 89 and later appearance improvements - https://github.com/black7375/Firefox-UI-Fix ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // userchrome.css usercontent.css activate
user_pref("svg.context-properties.content.enabled", true); // Fill SVG Color
user_pref("layout.css.backdrop-filter.enabled", true); // CSS Blur Filter - 88 Above
user_pref("layout.css.color-mix.enabled", true); // CSS Color Mix - 88 Above
user_pref("browser.tabs.drawInTitlebar", true); // Draw in Titlebar
user_pref("browser.compactmode.show", true); // Restore Compact Mode - 89 Above
user_pref("browser.urlbar.suggest.calculator", false); // Integrated calculator at urlbar
user_pref("security.default_personal_cert", "Select Automatically");
user_pref("browser.proton.enabled", true); // Proton Enabled #127
user_pref("browser.proton.places-tooltip.enabled", true); // Proton Tooltip
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false); // about:home Search Bar - 89 Above

/*** Don't forget to remove and reset deprecated refs in the 9999 section of the default file ***/
