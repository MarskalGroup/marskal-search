### List of column filter shortcuts for `MarskalSearch`
---

#### Quick Reference

| Short Code  | SQL             | [`User Input`]      | Gets all data where field... 
| ----------  | -------------   | ----------------  | ---------------------------------------
| %  		  | LIKE            | [`% 2015%`]         | ..starts with `2015`
|             |                 | [`% %Status`]       | ..ends with `Status`
|             |                 | [`% 17725`]         | ..equal to 17725  
| !%  		  | NOT LIKE        | [`!% 2015%`]        | ..does not start with `2015`
|             |                 | [`!% %Status`]      | ..does not end with `Status`
|             |                 | [`!% 17725`]        | ..not equal to `17725`  
| ~  		  | CONTAINS        | [`~ approved`]      | ..contains the word `approved`
| !~  		  | NOT CONTAINS    | [`!~ approved`]     | ..does not contain the word `approved`   
| ::  		  | BETWEEN         | [`:: 1&&3`]         | ..between the numbers of `1` AND `3`
| !::  		  | NOT BETWEEN     | [`:: 1&&3`]         | ..NOT between the numbers of `1` AND `3`   
| >  		  | >               | [`> 4`]             | ..greater than `4`   
| \<  		  | \<              | [`< 4`]             | ..less than `4`   
| >=  		  | >=              | [`>= 4`]            | ..greater than or equal to `4`   
| \<=  		  | \<=             | [`<= 4`]            | ..less than or equal to `4`
| =  		  | =               | [`= 4`]             | ..equal to `4`   
| !=  		  | !=              | [`!= 4`]            | ..NOT equal to `4`


---
Back to [README.md](../README.md)

