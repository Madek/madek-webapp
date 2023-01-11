"Big list of naughty strings"

The data file `blns-orig.json` was copied from https://github.com/minimaxir/big-list-of-naughty-strings 
(commit db33ec7 from Apr 17, 2021)

Until 2023 the list was referenced as an NPM module (https://www.npmjs.com/package/big-list-of-naughty-strings), but this is not up to date and contains mistakes. 

The list which is used now (`blns-reduced.json`) removes all examples which are just plain alphanumeric ascii (numbers, yswear words, "null", "COM1", etc.) because they are not interesting in our scenario. We just test that all these strings (except the whitespace-only ones) can be stored in the db without being scrumbled, and that they are displayed correctly in the web app. There is no reason why this should not be the case for something like "COM1". 
