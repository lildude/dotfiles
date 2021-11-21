
/*** My arkenfox user.js overrides - see https://github.com/arkenfox/user.js/wiki/3.3-Updater-Scripts ***/
user_pref("lildude.canary.in.a.coalmine", "overrides: started"); // canary for if I've made a mistake below 

user_pref("browser.startup.page", 3); // 0102 - I want my previous session restored cos crashes
user_pref("browser.startup.homepage", "moz-extension://2e261119-0837-c54f-8aa1-c96aa41ee1f4/dashboard.html"); // 0103 - I use the Momentum extension
user_pref("browser.search.region", "GB"); // 0201b - [HIDDEN PREF] I like my language proper
user_pref("intl.accept_languages", "en-gb,en"); // 0207 - cos english
user_pref("app.update.auto", true); // 0302a - I need this as Okta is a PITA if I don't have an up-to-date version
// JUST IN CASE: `extensions.formautofill.*` in 0517 all disabled in favour of 1Password
user_pref("extensions.pocket.enabled", true); // 0510 - I like Pocket
user_pref("network.dns.disableIPv6", false); // 0701 - I need IPv6
user_pref("network.proxy.socks_remote_dns", true); // 0704 - I might need to disable this when proxying through SSH.
user_pref("keyword.enabled", true); // 0801 - I like using the URL bar for easy searching
user_pref("browser.formfill.enable", true); // 0860 - I'm lazy
user_pref("security.ask_for_password", 0); // 0903 - I don't use Firefox's password manager, but in case it starts prompting, only the first time.
user_pref("security.password_lifetime", 30); // 0904 - As for 0903

user_pref("browser.cache.disk.enable", true); // 1001 - I use temp containers and a lot of tabs
user_pref("browser.sessionstore.privacy_level", 0); // 1021 - I'm not sure about this just yet so sticking with default

user_pref("security.mixed_content.block_display_content", false); // 1241 - Breaks a lot of sites
user_pref("browser.display.use_document_fonts", 1); // 1401 - I want pretty fonts for now
user_pref("media.gmp-widevinecdm.enabled", true); // 1825 - I likes Netflix
user_pref("media.gmp-widevinecdm.visible", true); // 1825 - I likes Netflix
user_pref("media.eme.enabled", true); // 1830 - I likes Netflix

user_pref("webgl.disabled", false); // 2010 - Strava and Mapbox playground needs WebGL
user_pref("webgl.enable-webgl2", true); // 2010 - Strava and Mapbox playground needs WebGL
user_pref("webgl.min_capability_mode", false); // 2012 - Strava and Mapbox playground needs WebGL
user_pref("webgl.disable-fail-if-major-performance-caveat", false); // 2012 - Strava and Mapbox playground needs WebGL
user_pref("dom.serviceWorkers.enabled", true); // 2302 - It breaks websites
user_pref("dom.allow_cut_copy", true); // 2404 - I need this for GitHub's copy permalink func
user_pref("beacon.enabled", true); // 2602 - github.rewatch.com used for work vids needs this
user_pref("browser.download.folderList", 1); // 2650 - Always download to downloads
user_pref("browser.download.useDownloadDir", true); // 2651 - I'm explicit in my setup so am happy to always go to downloads
user_pref("privacy.sanitize.sanitizeOnShutdown", false); // 2802 - Don't clear things everytime I shutdown
user_pref("privacy.clearOnShutdown.offlineApps", false); // cos 2802 is false

user_pref("privacy.firstparty.isolate", false); // 4001 - Breaks stuff
user_pref("privacy.resistFingerprinting", false); // 4501 - this breaks Okta login
user_pref("privacy.resistFingerprinting.letterboxing", false); // 4504
// 4600: These are enabled here because I've disabled 4501. Some of these might interfer with sites
user_pref("dom.enable_resource_timing", false); // 4602
user_pref("dom.enable_performance", false); // 4603
user_pref("browser.zoom.siteSpecific", false); // 4605
user_pref("media.webspeech.synth.enabled", false); // 4608
user_pref("media.video_stats.enabled", false); // 4610
user_pref("media.ondevicechange.enabled", false); // 4612
user_pref("webgl.enable-debug-renderer-info", false); // 4613
user_pref("ui.use_standins_for_native_colors", true); // 4615

/*** ANO non-ghacks settings ***/
user_pref("security.enterprise_roots.enabled", true); // Trust keychain company certs - might work one day - https://www.jamf.com/jamf-nation/discussions/25166/how-to-firefox-trusting-company-certificates
user_pref("security.osclientcerts.autoload", true);
user_pref("accessibility.typeaheadfind.flashBar", 0); // I don't want the toolbar to flash when a find matches

/*** Firefox 89 and later appearance improvements - https://github.com/black7375/Firefox-UI-Fix ***/
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true); // userchrome.css usercontent.css activate
user_pref("svg.context-properties.content.enabled", true); // Fill SVG Color
user_pref("layout.css.backdrop-filter.enabled", true); // CSS Blur Filter - 88 Above
user_pref("browser.compactmode.show", true); // Restore Compact Mode - 89 Above
// about:home Search Bar
// user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false);
// ** Useful Options ***********************************************************

user_pref("browser.urlbar.suggest.calculator", true); // Integrated calculator at urlbar

/*** Don't forget to remove and reset deprecated refs in the 9999 section of the default file ***/
