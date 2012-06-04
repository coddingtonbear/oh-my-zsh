function current_timebook_status(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "
        SELECT
            end_time, 
            CASE WHEN length(description) > 0 then description else Null end as description, 
            ROUND((strftime('%s', 'now') - start_time) / CAST(3600 AS FLOAT), 2),
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
    end_time=$ref[(ws:|:)1];
    description=$ref[(ws:|:)2];
    hours=$ref[(ws:|:)3];
    ticket=$ref[(ws:|:)4];
    billable_string=$ref[(ws:|:)5];
    if [[ $billable_string == "yes" ]]; then
        billable="";
    else;
        billable="(¬$) ";
    fi;
    if [[ $description == "NULL" ]]; then
        description_string="";
    else;
        description_string="\"${description}\" ";
    fi;
    if [[ $ticket == "NULL" ]]; then
        ticket_string="(No Ticket #) ";
    else;
        ticket_string="#${ticket} ";
    fi;
    if [[ $end_time == "NULL" ]]; then
        echo "[${ticket_string}${description_string}${billable}${hours}h] "
    fi;
}

function set_current_timesheet_balance(){
    raw=$(t hours --param=balance 2> /dev/null);
    TIMESHEET_BALANCE=$(printf "%.2f" $raw);
}

function current_timesheet_balance(){
    if [[ $TIMESHEET_BALANCE -lt 0 ]]; then
        color=$FG[124]
    elif [[ $TIMESHEET_BALANCE -lt 0 ]]; then
        color=$FG[166]
    else
        color=$FG[154]
    fi;
    if [[ $TIMESHEET_BALANCE != "NULL" ]]; then
        echo "${color}[${TIMESHEET_BALANCE}h]"
    fi;
}

function daily_timesheet_balance(){
    ref=$(sqlite3 -nullvalue 'NULL' ~/.config/timebook/sheets.db "
        SELECT
            ROUND(SUM(COALESCE(end_time, strftime('%s', 'now')) - start_time) / CAST(3600 AS FLOAT), 1)
        FROM entry
        WHERE sheet = 'default' and entry.start_time > strftime('%s', strftime('%Y-%m-%d', 'now', 'localtime'), 'utc')
        " 2> /dev/null) || return
    curr_hours=$ref[(ws:|:)1];
    if [[ $curr_hours -lt 7 ]]; then
        color=$FG[124]
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

PERIOD=60
add-zsh-hook periodic set_current_timesheet_balance
