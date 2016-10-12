
set +x
set -u

unset -f human_seconds

function human_seconds() {
    local SECS=${1:-}
    local PARAM=${2:-}

    [ -z "${SECS}" ]  && return

    function plural() {
        if [ $1 -eq 1 ]; then
            echo "$1 $2"
        elif [ $1 -gt 1 ]; then
            echo "$1 $2s"
        fi
    }
    
    local and=0
    local year=
    local s=
    local week=
    local day=
    local hour=
    local minute=
    local second=

    (( year=$SECS/31536000 ))
    (( s=$SECS-$year*31536000 ))
    ((
        week=$s/604800,
        day=$s/86400%7,
        hour=$s/3600%24,
        minute=$s/60%60,
        second=$s%60
    ))
    
    if [ $PARAM ]; then
        [ $PARAM = "minutes" ] && let second=0
        [ $PARAM = "hours" ] && let {second,minute}=0
        [ $PARAM = "days" ] && let {second,minute,hour}=0
        [ $PARAM = "weeks" ] && let {second,minute,hour,day}=0
        [ $PARAM = "years" ] && let {second,minute,hour,day,week}=0
    fi

    local result=
    local period= 
    for period in second minute hour day week year; do
        [ ${!period} -gt 0 ] && [ $and -eq 1 ] && result="and $result"
        [ ${!period} -gt 0 ] && result="$(plural ${!period} $period) $result" && (( and=$and+1 ))
    done


    [ -z "$result" ] && result="0 $PARAM"
    echo $result
    unset plural
}

#caller

human_seconds ${1:-} #${2:-seconds}
unset -f human_seconds


