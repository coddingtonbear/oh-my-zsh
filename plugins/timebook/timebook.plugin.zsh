function current_timebook_status(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "SELECT end_time, description, ROUND((strftime('%s', 'now') - start_time) / CAST(3600 AS FLOAT), 2) FROM entry WHERE id = (select max(id) from entry);" 2> /dev/null) || return
    end_time=$ref[(ws:|:)1];
    doc_status=$ref[(ws:|:)2];
    hours=$ref[(ws:|:)3];
    if [[ $end_time == "NULL" ]]; then
        echo "[${doc_status} ${hours}h] "
    else
        return
    fi
}

function current_timesheet_balance(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "SELECT ROUND(SUM(COALESCE(end_time, strftime('%s', 'now')) - start_time) / CAST(3600 AS FLOAT), 1) from entry where sheet = 'default' and entry.start_time > strftime('%s', strftime('%Y-%m-%d', 'now', 'localtime'), 'utc')" 2> /dev/null) || return
    curr_hours=$ref[(ws:|:)1];
    if [[ $curr_hours -lt 7 ]]; then
        color=$FG[125]
    elif [[ $curr_hours -lt 7.5 ]]; then
        color=$FG[142]
    elif [[ $curr_hours -lt 8 ]]; then
        color=$FG[120]
    else
        color=$FG[154]
    fi
    echo "${color}[${curr_hours}h] "
}
