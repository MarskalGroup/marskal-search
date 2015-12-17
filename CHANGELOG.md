### Change log `(Revision History)`
---

###### v0.3.6 [`2015-12-16 by MAU`]
* added column details method
* I still need to integrate it in

---
###### v0.3.5 [`2015-12-16 by MAU`]
* renamed parameter create_table: to create_model
* changed the way I create a new dymanic moel
* added Utils class 

---
###### v0.3.4 [`2015-12-15 by MAU`]
* Added ability to dynamical create a model via 'create_table:' option
* Added .table_name and .database getters/readers to display the database and table name associated with model 

---
###### v0.3.3 [`2015-12-15 by MAU`]
* Modified call to remove paramater 2 and make it an option
* Added shortccut functionality to the class
* add :search_text key with shortcut :q 

---
###### v0.3.2 [`2015-12-15 by MAU`]
* Reasonable FirstVersion of help completed
* wrap_column: has been used for an example

---
###### v0.3.1 [`2015-12-14 by MAU`]
* WIP cleanup documentation via help module
* working on "\n" problems

---
###### v0.3.0 [`2015-12-14 by MAU`]
* starting rewrite of methods and adding help
* this is only a semi-working version

---
###### v0.2.4 [`2015-12-14 by MAU`]
* snapshot before major cleanup for marksla api and search tools

---
###### v0.2.3 [`2015-12-13 by MAU`]
* started beginning of transition options || to options.has_key?
* add some tuning for unfiltered counts and regular counts as well

---
###### v0.2.2 [`2015-12-11 by MAU`]
* Added a concat for queries
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

