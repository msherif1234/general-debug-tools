#!/usr/bin/env bash
#
#set -x

function log {
    echo "$(TZ=Z date +%FT%TZ) $0: $*"
}

function yell {
    echo "$(TZ=Z date +%FT%TZ) $0: $*" >&2
}

timestamp() {
    IFS=":." read -r h m s ms<<<"$1"
    ret_val=$(( (h*3600 + m*60 + $((10#$s))) ))     
}

# identify ovnkube-master leader pod
function get_pattern {
    for p in $(oc -n openshift-sdn get pods -l app=sdn \
        -o jsonpath="{.items[*].metadata.name}")
    do
      begin_pattern=$(oc logs -n openshift-sdn "$p" -c sdn | grep -E "Starting openshift-sdn network plugin" | awk '{print $2}')
      end_pattern=$(oc logs -n openshift-sdn "$p" -c sdn | grep -E "openshift-sdn network plugin ready" | awk '{print $2}')

      echo "******************$p*************"

      timestamp "$end_pattern"
      etime=$ret_val
      timestamp "$begin_pattern"
      btime=$ret_val

      echo "Plugin Start: $begin_pattern"
      echo "Plugin Ready: $end_pattern"
      echo "Time diff(s): $(( $etime - $btime ))"
    done
}

get_pattern

