/*
	This companion script extracts all (3000+) preferences from about:config and
	dumps them to the console, in a list formatted as a user.js file.

	Usage:
		1. Open the console (Ctrl+Shift+J).
		2. Go to about:config and stay in that tab.
		3. Open the Scratchpad (Shift+F4) and open/paste this script.
		4. Run the script.
		5. Switch to the console and expand the entry generated by this script.
		6. Right click the entry > Copy message.
		7. Paste in your editor of choice.
		8. Make sure to remove the leading and trailing text from the log entry,
		especially if you intend to use the file for something other than comparisons.

	Note: In old versions of Firefox (or forks based on such versions) you may
	need/want to try a different solution like @Theemim's GeckoPrefsExporter:

	https://github.com/Theemim/GeckoPrefsExporter

*/

var result = [];
var prefs = Services.prefs.getChildList('');

for (const i in prefs){
	var p = prefs[i].replace(/"/g, '\\"');
	switch (Services.prefs.getPrefType(prefs[i])) {
		case 32:
			var v = Services.prefs.getStringPref(prefs[i]).replace(/"/g, '\\"');
			result.push(`user_pref("${p}", "${v}");`);
			break;
		case 64:
			var v = Services.prefs.getIntPref(prefs[i]).toString();
			result.push(`user_pref("${p}", ${v});`);
			break;
		case 128:
			var v = Services.prefs.getBoolPref(prefs[i]).toString();
			result.push(`user_pref("${p}", ${v});`);
			break;
		default:
			result.push(`//user_pref("${p}", ???);`);
	}
}

console.log(result.join('\n'));
