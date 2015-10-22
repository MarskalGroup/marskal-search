/**
 * Created by mikeu on 10/22/2015.
 */

var SQL_MANUAL_SHORT_CODES = ['<', '>', '!=', '=', '>=', '<=', '::', '!::', '!', ':', '%', '~', '!~', '^', '~^']

function anyIncompleteManualFilters(p_fields_selector) {
    var l_incomplete = false;
    p_fields_selector.each(function( index ) {
        if ($(this).val() && isManualSqlFilter($(this).val())) {
            l_incomplete = true;
            return( false );
        }
    });
    return l_incomplete;
}

function isManualSqlFilter(p_value) {
    var betweens = ['::', '!::'];
    var ins = ['^', '!^'];
    var l_found = false;
console.log('in isManualSqlFilter');
    if (betweens.indexOf(p_value.split(' ')[0])  >= 0) {
        var l_range = p_value.split('&&');              //the && seperates the range values in the between
        l_found = (l_range.length <= 1 || l_range[1]=='');      //if the have not completed the range, then we set found to false to prevent calling program from executing search
    }
    else if (ins.indexOf(p_value.split(' ')[0])  >= 0) {
        var l_range = p_value.split(',');              //the && seperates the range values in the between
        l_found = (l_range.length <= 1 || l_range[1]=='');      //if the have not completed the range, then we set found to false to prevent calling program from executing search
    }
    else
        l_found = SQL_MANUAL_SHORT_CODES.indexOf(p_value.trim())>= 0;

    return  l_found
}

