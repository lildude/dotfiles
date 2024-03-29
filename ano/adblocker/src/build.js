/**
 * Creates an Adblock list to filter out domains from search results.
 */

 const { readFileSync, writeFileSync } = require("fs");
 const { join } = require("path");

 let output = `! Title: Crap search engine results
 ! Description: Remove certain domains from Google/DuckDuckGo
 ! Homepage: https://github.com/lildude/dotfiles/
 !
 ! See also: https://gist.github.com/quenhus/6bd2c47e5780f726f0c96c0a2ee762a4
 !
 ! Origin: https://github.com/darekkay/config-files
 `;

 const source = readFileSync(join(__dirname, "search-results.txt"), "utf-8");
 const searchLines = source.split("\n");
// My own list of domains to remove from search results.
 const additional = readFileSync(join(__dirname, "additional.txt"), "utf-8");
 const addLines = additional.split("\n");

 const fileLines = new Set([...searchLines, ...addLines]);

 // Domains
 output += "\n! Domains\n\n";
 fileLines.forEach(line => {
   if (line.trim() === "" || line.startsWith("!")) {
     output += `${line}\n`;
   } else {
     output += `*://${line}/*\n`;
   }
 });

 // DuckDuckGo
 output += "\n! DuckDuckGo\n\n";
 fileLines.forEach(line => {
   if (line.trim() === "" || line.startsWith("!")) {
     output += `${line}\n`;
   } else {
     output += `duckduckgo.com###links>div:has(a[href*="${line}"])\n`;
   }
 });

 // Google
 output += "\n! Google\n\n";
 fileLines.forEach(line => {
   if (line.trim() === "" || line.startsWith("!")) {
     output += `${line}\n`;
   } else {
     output += `google.*##.g:has(a[href*="${line}"])\n`;
   }
 });

 writeFileSync(join(__dirname, "..", "search-results.txt"), output);
 console.log("Updated 'search-results' filter list.")
