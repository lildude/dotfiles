#!/usr/bin/env python3
"""Generate clickable Splunk search URLs from SPL queries.

Usage:
    python3 splunk_url.py "search index=prod-resque ..."
    python3 splunk_url.py --earliest=-1h --latest=now "search index=rails ..."
    python3 splunk_url.py --name="My query" "search index=prod-resque ..."

Outputs a plain URL, or a markdown-formatted link when --name is provided.
"""

import argparse
import urllib.parse

SPLUNK_WEB_BASE = "https://splunk.githubapp.com"


def splunk_search_url(spl: str, earliest: str = "-24h", latest: str = "now") -> str:
    encoded = urllib.parse.quote(spl, safe="")
    earliest_encoded = urllib.parse.quote(str(earliest), safe="")
    latest_encoded = urllib.parse.quote(str(latest), safe="")
    return f"{SPLUNK_WEB_BASE}/en-US/app/search/search?q={encoded}&earliest={earliest_encoded}&latest={latest_encoded}"


def main():
    parser = argparse.ArgumentParser(description="Generate clickable Splunk search URLs")
    parser.add_argument("spl", help="SPL query string")
    parser.add_argument("--earliest", default="-24h", help="Start of time range (default: -24h)")
    parser.add_argument("--latest", default="now", help="End of time range (default: now)")
    parser.add_argument("--name", default=None, help="Display name for the markdown link")
    args = parser.parse_args()

    url = splunk_search_url(args.spl, args.earliest, args.latest)

    if args.name:
        print(f"- [{args.name}]({url})")
    else:
        print(url)


if __name__ == "__main__":
    main()
