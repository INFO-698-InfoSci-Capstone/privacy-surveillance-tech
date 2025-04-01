# README for WAYBACK MACHINE SCRAPER

Code to retrieve data from the **Wayback Machine** using the *Wayback CDX Server API*: https://github.com/internetarchive/wayback/tree/master/wayback-cdx-server


## Overview 
The following Python script retrieves Facebook Community Standards websites between 2011 and March 2025 stored in the Internet Archive as captures. The script:
1. Creates an output directory and file, and functions to load and save the scraping progess. 
2. Queries and fetches the the CDX data (captures) from the Wayback Machine for the URL facebook.com/communitystandards between 2011 and March 2025, using the resumption key approach. The function includes error handling and retry logic for timeouts.
3. Filter captures so that if a single day has:
    - two (2) captures, keep both for later comparison
    - more than 2 captures, pick random samples:
        - up to 5 captures, pick 1 random
        - up to 10 captures, pick 2 random
        - up to 20 captures, pick 3 random
        - more than 20 captures, pick 5 random
4. Retrieve and store the HTML content for each selected capture.
5. Follow “internal” sub-links (within facebook.com/communitystandards/...) recursively, up to any depth, storing those pages as well. *This function needs adjustments. Did not fetch any links*
6. Record external links in the content (but don’t follow them).
7. Compare versions (automated diff) to detect changes in content between captures.
8. Handle rate limits (via timeouts and delays).
9. Log progress (date and URL) so you can resume if the script halts.


##### Libraries
`requests` (HTTP requests)
`beautifulsoup4` (HTML parsing)
`difflib` (Computing text differences)
`random` (random pick of captures)
`time` (for delays)
`os` (create, access, and modify directories and files)
`json` (use JSON files)

***

## Purpose of the study
Trace and explain the evolution of Meta (facebook) content moderation policies between 2011 and the present day

***

## Dependencies
##### The run order for the scripts: 
1. Execute the script in the established order. Be sure to specify where the directory and files created are to be located
##### The script "WAYBACK_MACHINE_SCRAPER.ipynb" is executable so long as all data are loaded into the environment
##### Several packages/libraries are required, so be certain to install this package before running any other code.

***
