
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
//user_pref("browser.formfill.enable", true); // 0810 - I'm lazy - disabled cos it was getting annoying with 1Password
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
//user_pref("network.cookie.lifetimePolicy", 0); // 2801 - Don't clear on shutdown
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
user_pref("browser.proton.enabled", true); // Proton Enabled #127 || Removed at 97 #328 (Maintained for compatibility with ESR)
user_pref("browser.proton.places-tooltip.enabled", true); // Proton Tooltip
user_pref("browser.newtabpage.activity-stream.improvesearch.handoffToAwesomebar", false); // about:home Search Bar - 89 Above
user_pref("layout.css.has-selector.enabled", true); // CSS's `:has()` selector #457 - 103 Above

// Browser Theme Based Scheme - Will be activate 95 Above
// user_pref("layout.css.prefers-color-scheme.content-override", 3);

// ** Theme Related Options ****************************************************
// == Theme Distribution Settings ==============================================
// The rows that are located continuously must be changed `true`/`false` explicitly because there is a collision.
// https://github.com/black7375/Firefox-UI-Fix/wiki/Options#important
user_pref("userChrome.tab.connect_to_window",          true); // Original, Photon
user_pref("userChrome.tab.color_like_toolbar",         true); // Original, Photon

user_pref("userChrome.tab.lepton_like_padding",        true); // Original
user_pref("userChrome.tab.photon_like_padding",       false); // Photon

user_pref("userChrome.tab.dynamic_separator",          true); // Original, Proton
user_pref("userChrome.tab.static_separator",          false); // Photon
user_pref("userChrome.tab.static_separator.selected_accent", false); // Just option
user_pref("userChrome.tab.bar_separator",             false); // Just option

user_pref("userChrome.tab.newtab_button_like_tab",     true); // Original
user_pref("userChrome.tab.newtab_button_smaller",     false); // Photon
user_pref("userChrome.tab.newtab_button_proton",      false); // Proton

user_pref("userChrome.icon.panel_full",                true); // Original, Proton
user_pref("userChrome.icon.panel_photon",             false); // Photon

// Original Only
user_pref("userChrome.tab.box_shadow",                 true);
user_pref("userChrome.tab.bottom_rounded_corner",      true);

// Photon Only
user_pref("userChrome.tab.photon_like_contextline",   false);
user_pref("userChrome.rounding.square_tab",           false);

// == Theme Compatibility Settings =============================================
// user_pref("userChrome.compatibility.accent_color",         true); // Firefox v103 Below
// user_pref("userChrome.compatibility.covered_header_image", true);
// user_pref("userChrome.compatibility.panel_cutoff",         true);
// user_pref("userChrome.compatibility.navbar_top_border",    true);
// user_pref("userChrome.compatibility.dynamic_separator",    true); // Need dynamic_separator

// user_pref("userChrome.compatibility.os.linux_non_native_titlebar_button", true);
// user_pref("userChrome.compatibility.os.windows_maximized", true);

// == Theme Custom Settings ====================================================
// -- User Chrome --------------------------------------------------------------
// user_pref("userChrome.theme.proton_color.dark_blue_accent", true);
// user_pref("userChrome.theme.monospace",                     true);

// user_pref("userChrome.decoration.disable_panel_animate",    true);
// user_pref("userChrome.decoration.disable_sidebar_animate",  true);
// user_pref("userChrome.decoration.panel_button_separator",   true);
// user_pref("userChrome.decoration.panel_arrow",              true);

// user_pref("userChrome.autohide.tab",                        true);
// user_pref("userChrome.autohide.tab.opacity",                true);
// user_pref("userChrome.autohide.tab.blur",                   true);
// user_pref("userChrome.autohide.tabbar",                     true);
// user_pref("userChrome.autohide.navbar",                     true);
// user_pref("userChrome.autohide.bookmarkbar",                true);
// user_pref("userChrome.autohide.sidebar",                    true);
// user_pref("userChrome.autohide.fill_urlbar",                true);
// user_pref("userChrome.autohide.back_button",                true);
// user_pref("userChrome.autohide.forward_button",             true);
// user_pref("userChrome.autohide.page_action",                true);
// user_pref("userChrome.autohide.toolbar_overlap",            true);
// user_pref("userChrome.autohide.toolbar_overlap.allow_layout_shift", true);

// user_pref("userChrome.hidden.tab_icon",                     true);
// user_pref("userChrome.hidden.tab_icon.always",              true);
// user_pref("userChrome.hidden.tabbar",                       true);
// user_pref("userChrome.hidden.navbar",                       true);
// user_pref("userChrome.hidden.titlebar_container",           true);
// user_pref("userChrome.hidden.sidebar_header",               true);
// user_pref("userChrome.hidden.sidebar_header.vertical_tab_only", true);
// user_pref("userChrome.hidden.urlbar_iconbox",               true);
// user_pref("userChrome.hidden.urlbar_iconbox.label_only",    true);
// user_pref("userChrome.hidden.bookmarkbar_icon",             true);
// user_pref("userChrome.hidden.bookmarkbar_label",            true);
// user_pref("userChrome.hidden.disabled_menu",                true);

// user_pref("userChrome.centered.tab",                        true);
// user_pref("userChrome.centered.tab.label",                  true);
// user_pref("userChrome.centered.urlbar",                     true);
// user_pref("userChrome.centered.bookmarkbar",                true);

// user_pref("userChrome.counter.tab",                         true);
// user_pref("userChrome.counter.bookmark_menu",               true);

// user_pref("userChrome.combined.nav_button",                 true);
// user_pref("userChrome.combined.nav_button.home_button",     true);
// user_pref("userChrome.combined.urlbar.nav_button",          true);
// user_pref("userChrome.combined.urlbar.home_button",         true);
// user_pref("userChrome.combined.urlbar.reload_button",       true);
// user_pref("userChrome.combined.sub_button.none_background", true);
// user_pref("userChrome.combined.sub_button.as_normal",       true);

// user_pref("userChrome.rounding.square_button",              true);
// user_pref("userChrome.rounding.square_panel",               true);
// user_pref("userChrome.rounding.square_panelitem",           true);
// user_pref("userChrome.rounding.square_menupopup",           true);
// user_pref("userChrome.rounding.square_menuitem",            true);
// user_pref("userChrome.rounding.square_field",               true);
// user_pref("userChrome.rounding.square_urlView_item",        true);
// user_pref("userChrome.rounding.square_checklabel",          true);

// user_pref("userChrome.padding.first_tab",                   true);
// user_pref("userChrome.padding.first_tab.always",            true);
// user_pref("userChrome.padding.drag_space",                  true);
// user_pref("userChrome.padding.drag_space.maximized",        true);

// user_pref("userChrome.padding.toolbar_button.compact",      true);
// user_pref("userChrome.padding.menu_compact",                true);
// user_pref("userChrome.padding.bookmark_menu.compact",       true);
// user_pref("userChrome.padding.urlView_expanding",           true);
// user_pref("userChrome.padding.urlView_result",              true);
// user_pref("userChrome.padding.panel_header",                true);

// user_pref("userChrome.urlbar.iconbox_with_separator",       true);

// user_pref("userChrome.urlView.as_commandbar",               true);
// user_pref("userChrome.urlView.full_width_padding",          true);
// user_pref("userChrome.urlView.always_show_page_actions",    true);
// user_pref("userChrome.urlView.move_icon_to_left",           true);
// user_pref("userChrome.urlView.go_button_when_typing",       true);
// user_pref("userChrome.urlView.focus_item_border",           true);

// user_pref("userChrome.tabbar.as_titlebar",                  true);
// user_pref("userChrome.tabbar.fill_width",                   true);
// user_pref("userChrome.tabbar.multi_row",                    true);
// user_pref("userChrome.tabbar.unscroll",                     true);
// user_pref("userChrome.tabbar.on_bottom",                    true);
// user_pref("userChrome.tabbar.on_bottom.above_bookmark",     true); // Need on_bottom
// user_pref("userChrome.tabbar.on_bottom.menubar_on_top",     true); // Need on_bottom
// user_pref("userChrome.tabbar.on_bottom.hidden_single_tab",  true); // Need on_bottom
// user_pref("userChrome.tabbar.one_liner",                    true);
// user_pref("userChrome.tabbar.one_liner.combine_navbar",     true); // Need one_liner
// user_pref("userChrome.tabbar.one_liner.tabbar_first",       true); // Need one_liner
// user_pref("userChrome.tabbar.one_liner.responsive",         true); // Need one_liner

// user_pref("userChrome.tab.bottom_rounded_corner.all",       true);
// user_pref("userChrome.tab.bottom_rounded_corner.australis", true);
// user_pref("userChrome.tab.bottom_rounded_corner.edge",      true);
// user_pref("userChrome.tab.bottom_rounded_corner.chrome",    true);
// user_pref("userChrome.tab.bottom_rounded_corner.chrome_legacy", true);
// user_pref("userChrome.tab.bottom_rounded_corner.wave",      true);
// user_pref("userChrome.tab.always_show_tab_icon",            true);
// user_pref("userChrome.tab.close_button_at_pinned",          true);
// user_pref("userChrome.tab.close_button_at_pinned.always",   true);
// user_pref("userChrome.tab.close_button_at_pinned.background", true);
// user_pref("userChrome.tab.close_button_at_hover.always",    true); // Need close_button_at_hover
// user_pref("userChrome.tab.close_button_at_hover.with_selected", true);  // Need close_button_at_hover
// user_pref("userChrome.tab.sound_show_label",                true); // Need remove sound_hide_label

// user_pref("userChrome.navbar.as_sidebar",                   true);

// user_pref("userChrome.bookmarkbar.multi_row",               true);

// user_pref("userChrome.findbar.floating_on_top",             true);

// user_pref("userChrome.panel.remove_strip",                  true);
// user_pref("userChrome.panel.full_width_separator",          true);
// user_pref("userChrome.panel.full_width_padding",            true);

// user_pref("userChrome.sidebar.overlap",                     true);

// user_pref("userChrome.icon.disabled",                       true);
// user_pref("userChrome.icon.account_image_to_right",         true);
// user_pref("userChrome.icon.account_label_to_right",         true);
// user_pref("userChrome.icon.menu.full",                      true);
// user_pref("userChrome.icon.global_menu.mac",                true);

// -- User Content -------------------------------------------------------------
// user_pref("userContent.player.ui.twoline",                  true);

// user_pref("userContent.newTab.hidden_logo",                 true);

// user_pref("userContent.page.proton_color.dark_blue_accent", true);
// user_pref("userContent.page.proton_color.system_accent",    true);
// user_pref("userContent.page.monospace",                     true);

// == Theme Default Settings ===================================================
// -- User Chrome --------------------------------------------------------------
user_pref("userChrome.compatibility.theme",       true);
user_pref("userChrome.compatibility.os",          true);

user_pref("userChrome.theme.built_in_contrast",   true);
user_pref("userChrome.theme.system_default",      true);
user_pref("userChrome.theme.proton_color",        true);
user_pref("userChrome.theme.proton_chrome",       true); // Need proton_color
user_pref("userChrome.theme.fully_color",         true); // Need proton_color
user_pref("userChrome.theme.fully_dark",          true); // Need proton_color

user_pref("userChrome.decoration.cursor",         true);
user_pref("userChrome.decoration.field_border",   true);
user_pref("userChrome.decoration.download_panel", true);
user_pref("userChrome.decoration.animate",        true);

user_pref("userChrome.padding.tabbar_width",      true);
user_pref("userChrome.padding.tabbar_height",     true);
user_pref("userChrome.padding.toolbar_button",    true);
user_pref("userChrome.padding.navbar_width",      true);
user_pref("userChrome.padding.urlbar",            true);
user_pref("userChrome.padding.bookmarkbar",       true);
user_pref("userChrome.padding.infobar",           true);
user_pref("userChrome.padding.menu",              true);
user_pref("userChrome.padding.bookmark_menu",     true);
user_pref("userChrome.padding.global_menubar",    true);
user_pref("userChrome.padding.panel",             true);
user_pref("userChrome.padding.popup_panel",       true);

user_pref("userChrome.tab.multi_selected",        true);
user_pref("userChrome.tab.unloaded",              true);
user_pref("userChrome.tab.letters_cleary",        true);
user_pref("userChrome.tab.close_button_at_hover", true);
user_pref("userChrome.tab.sound_hide_label",      true);
user_pref("userChrome.tab.sound_with_favicons",   true);
user_pref("userChrome.tab.pip",                   true);
user_pref("userChrome.tab.container",             true);
user_pref("userChrome.tab.crashed",               true);

user_pref("userChrome.fullscreen.overlap",        true);
user_pref("userChrome.fullscreen.show_bookmarkbar", true);

user_pref("userChrome.icon.library",              true);
user_pref("userChrome.icon.panel",                true);
user_pref("userChrome.icon.menu",                 true);
user_pref("userChrome.icon.context_menu",         true);
user_pref("userChrome.icon.global_menu",          true);
user_pref("userChrome.icon.global_menubar",       true);

// -- User Content -------------------------------------------------------------
user_pref("userContent.player.ui",             true);
user_pref("userContent.player.icon",           true);
user_pref("userContent.player.noaudio",        true);
user_pref("userContent.player.size",           true);
user_pref("userContent.player.click_to_play",  true);
user_pref("userContent.player.animate",        true);

user_pref("userContent.newTab.full_icon",      true);
user_pref("userContent.newTab.animate",        true);
user_pref("userContent.newTab.pocket_to_last", true);
user_pref("userContent.newTab.searchbar",      true);

user_pref("userContent.page.field_border",     true);
user_pref("userContent.page.illustration",     true);
user_pref("userContent.page.proton_color",     true);
user_pref("userContent.page.dark_mode",        true); // Need proton_color
user_pref("userContent.page.proton",           true); // Need proton_color

// ** Useful Options ***********************************************************
// Integrated calculator at urlbar
user_pref("browser.urlbar.suggest.calculator", true);

// Integrated unit convertor at urlbar
// user_pref("browser.urlbar.unitConversion.enabled", true);

// Draw in Titlebar
// user_pref("browser.tabs.drawInTitlebar", true);
// user_pref("browser.tabs.inTitlebar",        1); // Nightly, 96 Above

// ** Scrolling Settings *******************************************************
// == Only Sharpen Scrolling ===================================================
//         Pref                                             Value      Original
/*
user_pref("mousewheel.min_line_scroll_amount",                 10); //        5
user_pref("general.smoothScroll.mouseWheel.durationMinMS",     80); //       50
user_pref("general.smoothScroll.currentVelocityWeighting", "0.15"); //   "0.25"
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6"); //    "0.4"
*/

// == Smooth Scrolling ==========================================================
// ** Scrolling Options ********************************************************
// based on natural smooth scrolling v2 by aveyo
// this preset will reset couple extra variables for consistency
//         Pref                                              Value                 Original
/*
user_pref("apz.allow_zooming",                               true);            ///     true
user_pref("apz.force_disable_desktop_zooming_scrollbars",   false);            ///    false
user_pref("apz.paint_skipping.enabled",                      true);            ///     true
user_pref("apz.windows.use_direct_manipulation",             true);            ///     true
user_pref("dom.event.wheel-deltaMode-lines.always-disabled", true);            ///    false
user_pref("general.smoothScroll.currentVelocityWeighting", "0.12");            ///   "0.25" <- 1. If scroll too slow, set to "0.15"
user_pref("general.smoothScroll.durationToIntervalRatio",    1000);            ///      200
user_pref("general.smoothScroll.lines.durationMaxMS",         100);            ///      150
user_pref("general.smoothScroll.lines.durationMinMS",           0);            ///      150
user_pref("general.smoothScroll.mouseWheel.durationMaxMS",    100);            ///      200
user_pref("general.smoothScroll.mouseWheel.durationMinMS",      0);            ///       50
user_pref("general.smoothScroll.mouseWheel.migrationPercent", 100);            ///      100
user_pref("general.smoothScroll.msdPhysics.continuousMotionMaxDeltaMS", 12);   ///      120
user_pref("general.smoothScroll.msdPhysics.enabled",                  true);   ///    false
user_pref("general.smoothScroll.msdPhysics.motionBeginSpringConstant", 200);   ///     1250
user_pref("general.smoothScroll.msdPhysics.regularSpringConstant",     200);   ///     1000
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaMS",         10);   ///       12
user_pref("general.smoothScroll.msdPhysics.slowdownMinDeltaRatio",  "1.20");   ///    "1.3"
user_pref("general.smoothScroll.msdPhysics.slowdownSpringConstant",   1000);   ///     2000
user_pref("general.smoothScroll.other.durationMaxMS",         100);            ///      150
user_pref("general.smoothScroll.other.durationMinMS",           0);            ///      150
user_pref("general.smoothScroll.pages.durationMaxMS",         100);            ///      150
user_pref("general.smoothScroll.pages.durationMinMS",           0);            ///      150
user_pref("general.smoothScroll.pixels.durationMaxMS",        100);            ///      150
user_pref("general.smoothScroll.pixels.durationMinMS",          0);            ///      150
user_pref("general.smoothScroll.scrollbars.durationMaxMS",    100);            ///      150
user_pref("general.smoothScroll.scrollbars.durationMinMS",      0);            ///      150
user_pref("general.smoothScroll.stopDecelerationWeighting", "0.6");            ///    "0.4"
user_pref("layers.async-pan-zoom.enabled",                   true);            ///     true
user_pref("layout.css.scroll-behavior.spring-constant",   "250.0");            ///   "250.0"
user_pref("mousewheel.acceleration.factor",                     3);            ///       10
user_pref("mousewheel.acceleration.start",                     -1);            ///       -1
user_pref("mousewheel.default.delta_multiplier_x",            100);            ///      100
user_pref("mousewheel.default.delta_multiplier_y",            100);            ///      100
user_pref("mousewheel.default.delta_multiplier_z",            100);            ///      100
user_pref("mousewheel.min_line_scroll_amount",                  0);            ///        5
user_pref("mousewheel.system_scroll_override.enabled",       true);            ///     true <- 2. If scroll too fast, set to false
user_pref("mousewheel.system_scroll_override_on_root_content.enabled", false); ///     true
user_pref("mousewheel.transaction.timeout",                  1500);            ///     1500
user_pref("toolkit.scrollbox.horizontalScrollDistance",         4);            ///        5
user_pref("toolkit.scrollbox.verticalScrollDistance",           3);            ///        3
*/


user_pref("network.cookie.sameSite.laxByDefault.disabledHosts", "admin.github.com"); // Lax SameSite Cookies exceptions - 96 Above

user_pref("security.default_personal_cert", "Select Automatically"); // Work added this one
/*** Don't forget to remove and reset deprecated refs in the 9999 section of the default file ***/
