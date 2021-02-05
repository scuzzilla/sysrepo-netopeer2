#!/usr/bin/env bash

# Author: Salvatore Cuzzilla
# em@il: salvatore.cuzzilla@swisscom.com  
# Starting date:    05-02-2021
# Last change date: 05-02-2021
# Release date:     TBD
# Description: extract NETCONF schemas directly from the devices


set -o errexit
set -o nounset
set -o pipefail

work_dir=$(dirname "$(readlink --canonicalize-existing "${0}" 2> /dev/null)")

readonly username="daisy"
readonly password="daisy" 
#readonly epoch=$(date +'%s'i)
readonly nc=$(which netconf-console 2> /dev/null)
readonly error_reading_file=80
readonly error_parsing_options=81
readonly error_missing_options=82
readonly error_unknown_options=83
readonly error_missing_options_arg=84
readonly error_unimplemented_options=85
readonly readonly script_name="${0##*/}"

f_option_flag=0
h_option_flag=0

trap clean_up ERR SIGINT SIGTERM

usage() {
  cat <<MAN
  Usage: ${script_name} [-f <ARG> ] || [-h]
  
  DESCRIPTION:
    this tool can be used the extract the NETCONF capabilities directly from the network
  
  OPTIONS:
    -h
      Print this help and exit
    -f
      [mandatory] Specify the list of devices - CSV Format: <hostname|ip>,<port>
    -u
      [wip/statically assigned] Specify the login credentials: username 
    -p
      [wip/statically assigned] Specify the login credentials: password 
MAN
}

clean_up() {
  if [[ -d "${work_dir}/capabilities_yangs/${pe_hostname}" ]]; then
    echo -e "Deleting: ${work_dir}/capabilities_yangs/${pe_hostname} ..."
    rm -rf "${work_dir}/capabilities_yang/${pe_hostname}"
  fi
}

die() {
  local -r msg="${1}"
  local -r code="${2:-90}"
  echo "${msg}" >&2
  exit "${code}"
}

parse_user_options() {
  while getopts ":f:h" opts; do
    case "${opts}" in
    f)
      f_option_flag=1
      readonly f_arg="${OPTARG}"
      ;;
#    u)
#      i_option_flag=1
#      readonly u_arg="${OPTARG}"
#      ;;
#    p)
#      i_option_flag=1
#      readonly p_arg="${OPTARG}"
#      ;;
    h)
      h_option_flag=1
      ;;
    :)
      die "error - mind your options/arguments - [ -h ] to know more" "${error_unknown_options}"
      ;;
    \?)
      die "error - mind your options/arguments - [ -h ] to know more" "${error_missing_options_arg}"
      ;;
    *)
      die "error - mind your options/arguments - [ -h ] to know more" "${error_unimplemented_options}"
      ;;
    esac
  done
}
shift $((OPTIND -1))

# Generating per host a folder containing the schemas (yang files)
# Input: <hostname|ip>/<port> & capabilities.lst file
# Output: schemas --> yang files
gen_capabilities_yangs() {
  if [[ ! -f "${f_arg}" ]]; then
    die "error - reading file: ${f_arg}" "${error_reading_file}"
  fi
  
  while read -r line
  do
    local host="$(echo "${line}" | awk -F "," '{print $1}')"
    local port="$(echo "${line}" | awk -F "," '{print $2}')"

    echo -e "${host}"
    local cap_list=$("${nc}" --host "${host}" --port "${port}" -u "${username}" -p "${password}" --hello | \
                     awk -F "module=" '{print $2}' | awk -F "&amp|</nc" '{print $1}' 2> /dev/null)
#    local cap_deviations=$("${nc}" --host "${host}" --port "${port}" -u "${username}" -p "${password}" \
#                           --timeout 30 --reply-timeout 30 --hello | awk -F "deviations=" '{print $2}' | awk -F "<" '{print $1}' 2> /dev/null)
    
    if [[ ! -d "${work_dir}/capabilities_yangs/${host}" ]]; then
      mkdir -p "${work_dir}/capabilities_yangs/${host}"
    fi

    for yang in $cap_list
    do
      echo -e "YANG - Extracting ${yang} from ${host} ..."
      $("${nc}" --host "${host}" --port "${port}" -u "${username}" -p "${password}" \
        --get-schema "${yang}" | awk -v RS='<[^>]+>' -v ORS= '1' > "${work_dir}/capabilities_yangs/${host}/${yang}.yang")
    done
    
#    for yang in $cap_deviations
#    do
#      echo -e "YANG Deviations - Extracting ${yang} from ${host} ..."
#      $("${nc}" --host "${host}" --port "${port}" -u "${username}" -p "${password}" \
#        --timeout 30 --reply-timeout 30 --get-schema "${yang}" > "${work_dir}/capabilities_yangs/${host}/${yang}.yang")
#    done
  done < "${f_arg}"
}

parse_user_options "${@}"

if ((h_option_flag)); then
  usage
  exit 0
fi

if ((f_option_flag)) ; then
  gen_capabilities_yangs
else 
  die "error - mind  your options/arguments - [ -h ] to know more" "${error_missing_options}"
fi

exit 0
