#!/usr/bin/env bash
# "Make sure all these arguments are filled in the correct position GITHUB_EMAIL,GITHUB_USERNAME,PROJECT_ID,SERVICE_ACCOUNT_NAME,GCP_USERNAME,GITHUB_BRANCH_NAME ex: bash ./initial_setup.sh example@gmail.com user_123 ferrous-weaver-256122 demo-service-account gcp_signup_name_3 dev-test"

# usage() { echo "Usage: $0 [-s <45|90>] [-p <string>]" 1>&2; exit 1; }
usage() { echo "Usage: bash $0 [-e GITHUB_EMAIL] [-u GITHUB_USERNAME] [-p PROJECT_ID] [-s SERVICE_ACCOUNT_NAME] [-g GCP_USERNAME] [-b GITHUB_BRANCH_NAME] | \
Example: bash $0 -e example@gmail.com -u user_123 -p ferrous-weaver-256122 -s demo-service-account -g gcp_signup_name_3 -b master" 1>&2; exit 1;}

while getopts ":e:u:p:s:g:b:" o; do
    case "${o}" in
        e)
            e=${OPTARG}
        ;;
        u)
            u=${OPTARG}
        ;;
        p)
            p=${OPTARG}
        ;;
        s)
            s=${OPTARG}
        ;;
        g)
            g=${OPTARG}
        ;;
        b)
            b=${OPTARG}
        ;;
        *)
            usage
        ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${e}" ] || [ -z "${u}" ] || [ -z "${p}" ] || [ -z "${s}" ] || [ -z "${g}" ] || [ -z "${b}" ]; then
    usage
fi

GITHUB_EMAIL=${e}
GITHUB_USERNAME=${u}
PROJECT_ID=${p}
SERVICE_ACCOUNT_NAME=${s}
GCP_USERNAME=${g}
GITHUB_BRANCH_NAME=${b}

echo "e = ${e}"
echo "u = ${u}"
echo "p = ${p}"
echo "s = ${s}"
echo "g = ${g}"
echo "b = ${b}"

echo "GITHUB_EMAIL = $GITHUB_EMAIL"
echo "GITHUB_USERNAME = $GITHUB_USERNAME"
echo "PROJECT_ID = $PROJECT_ID"
echo "SERVICE_ACCOUNT_NAME = $SERVICE_ACCOUNT_NAME"
echo "GCP_USERNAME = $GCP_USERNAME"
echo "GITHUB_BRANCH_NAME = $GITHUB_BRANCH_NAME"

# a_flag=''
# b_flag=''
# files=''
# verbose='false'

# print_usage() {
#     printf "Usage: ..."
# }

# while getopts 'a:b:f:v' flag; do
#     case "${flag}" in
#         a) a_flag='true' ;;
#         b) b_flag='true' ;;
#         f) files="${OPTARG}" ;;
#         v) verbose='true' ;;
#         *) print_usage
#         exit 1 ;;
#     esac
# done

# while test $# -gt 0; do
#     case "$1" in
#         -h|--help)
#             echo "$package - attempt to capture frames"
#             echo " "
#             echo "$package [options] application [arguments]"
#             echo " "
#             echo "options:"
#             echo "-h, --help                show brief help"
#             echo "-a, --action=ACTION       specify an action to use"
#             echo "-o, --output-dir=DIR      specify a directory to store output in"
#             exit 0
#         ;;
#         -a)
#             shift
#             if test $# -gt 0; then
#                 export PROCESS=$1
#             else
#                 echo "no process specified"
#                 exit 1
#             fi
#             shift
#         ;;
#         --action*)
#             export PROCESS=`echo $1 | sed -e 's/^[^=]*=//g'`
#             shift
#         ;;
#         -o)
#             shift
#             if test $# -gt 0; then
#                 export OUTPUT=$1
#             else
#                 echo "no output dir specified"
#                 exit 1
#             fi
#             shift
#         ;;
#         --output-dir*)
#             export OUTPUT=`echo $1 | sed -e 's/^[^=]*=//g'`
#             shift
#         ;;
#         *)
#             break
#         ;;
#     esac
# done