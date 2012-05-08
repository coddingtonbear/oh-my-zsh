function current_timebook_status(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "
        SELECT
            end_time, description, ROUND((strftime('%s', 'now') - start_time) / CAST(3600 AS FLOAT), 2),
            em_ticket.value,
            em_billable.value,
            Null
        FROM entry e
        LEFT OUTER JOIN entry_meta em_ticket ON
            e.id = em_ticket.entry_id
            and
            em_ticket.key = 'ticket_number'
        LEFT OUTER JOIN entry_meta em_billable ON
            e.id = em_billable.entry_id
            and
            em_billable.key = 'billable'
        WHERE id = (
            SELECT max(id) 
            FROM entry 
            WHERE sheet = 'default'
        );
        " 2> /dev/null) || return
    ref=${ref// /};
    end_time=$ref[(ws:|:)1];
    doc_status=$ref[(ws:|:)2];
    hours=$ref[(ws:|:)3];
    ticket=$ref[(ws:|:)4];
    billable_string=$ref[(ws:|:)5];
    if [[ $billable_string == "yes" ]]; then
        billable="";
    else;
        billable="(¬$) ";
    fi;
    if [[ $end_time == "NULL" ]]; then
        echo "[#${ticket}, \"${doc_status}\" ${billable}${hours}h] "
    fi;
}

function current_timesheet_balance(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "
        SELECT
            ROUND(SUM(COALESCE(end_time, strftime('%s', 'now')) - start_time) / CAST(3600 AS FLOAT), 1)
        FROM entry
        WHERE sheet = 'default' and entry.start_time > strftime('%s', strftime('%Y-%m-%d', 'now', 'localtime'), 'utc')
        " 2> /dev/null) || return
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
    if [[ $curr_hours != "NULL" ]]; then
        echo "${color}[${curr_hours}h] "
    fi
}
