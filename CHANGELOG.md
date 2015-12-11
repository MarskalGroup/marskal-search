### Change log `(Revision History)`
---

###### v0.2.1 [`2015-12-10 by MAU`]
* Many Bug Fixes and changes to accommodate marskal-api
* Bug Fixes
    * Added COLUMN_DELIMTER or ` to wrap column names to prevent myssql erros. This was discoverd because 'primary' is a mysaql reserved word and also a field ion the database
    * fixed the way total pages are calculated
    * spelled :marskal-api correctly   
    * fixed problem with single column searches truncating the returned value from DB                   
* Marskal-api Integration
    * Added page to paramaters as an alternative to offset
    * Enhanced the return has results for marskal and default
        * Now Includes total page counts, page number and more
---
###### v0.2.0 [`2015-12-09 by MAU`]
* Added Integration with marskal-api
* tweaked handling of pass_back option

---
###### v0.1.5 [`2015-11-04 by MAU`]
* Fixed A Missing Function Call
* Removed a console.log line from js file

---
###### v0.1.4 [`2015-10-22 by MAU`]
* Fixed/cleaned up some [README.md](README.md) issues
* Removed completed items from [TODO.md](supplimental_documentation/TODO.md)

---
###### v0.1.3 [`2015-10-21 by MAU`]
* Fixed problem where IN was overtaking CONTAINS filters..beacuse "IN" is part of the word contaINs

---
###### v0.1.2 [`2015-10-21 by MAU`]
* Added IN/NOT IN short codes `^` and `!^`

---
###### v0.1.1 [`2015-10-21 by MAU`]
* Added Contains/not contains short codes `~` and `!`
* Added [Shortcut Quick Reference](SHORTCUTS.md)

---
###### v0.1.0 [`2015-10-21 by MAU`]
* Initial Commit

