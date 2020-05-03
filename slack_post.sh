#!/bin/bash

PROGNAME=$(basename $0)
VERSION="1.0"
# jq install error
command -v jq >/dev/null 2>&1 || { echo >&2 "$PROGNAME require jq but it's not installed. Install jq first."; exit 1; }

# $SLACK_WHURL error
: "${SLACK_WHURL:?Need to set SLACK_WHURL non-empty}"

usage() {
    echo "Usage: echo 'message' | $PROGNAME [OPTIONS]"
    echo "  This script can post a message to slack."
    echo "  You need to get slack webhook URL from "
    echo "  https://api.slack.com/messaging/webhooks"
    echo "  and set it in \$SLACK_WHURL"
    echo
    echo "Options:"
    echo "  -h, --help"
    echo "      --dry-run"
    echo "          Print JSON text to preview your post."
    echo "      --version"
    echo "  -c, --channel ARG"
    echo "          '#channel' post to the channel. '@user' to post to a user."
    echo "          By default, post to default channel set on webhook."
    echo "  -u, --username ARG"
    echo "          Slack bot name."
    echo "  -t, --text ARG"
    echo "  -e, --icon_emoji ARG"
    exit 1
}

# set default parametors for payload
channel=""  # POST to default channel of webhook
username="webhookbot:$(whoami)@$(hostname)"
text="Message from Slack Webhook"
icon_emoji=":robot_face:"
dry=0

# get message text from standard input
if [ -p /dev/stdin ]; then
    text=$(cat -)
fi

for OPT in "$@"
do
    case $OPT in
        -h | --help)
            usage
            exit 1
            ;;
        --version)
            echo $VERSION
            exit 1
            ;;
        -c | --channel)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            channel=$2
            shift 2
            ;;
        -u | --username)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            username=$2
            shift 2
            ;;
        -t | --text)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- $1" 1>&2
                exit 1
            fi
            text=$2
            shift 2
            ;;
        -e | --icon_emoji)
            if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
                shift
            fi
            icon_emoji=$2
            shift 2
            ;;
        --dry-run)
            dry=1
            shift 1
            ;;
        -- | -)
            shift 1
            param+=( "$@" )
            break
            ;;
        -*)
            echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                #param=( ${param[@]} "$1" )
                param+=( "$1" )
                shift 1
            fi
            ;;
    esac
done

# generate payload
payload=$(cat << EOS
{
    "username":   "${username}",
    "text":       "${text}",
    "icon_emoji": "${icon_emoji}"
}
EOS
)

# add additional key to payload
# for 'channel'
if [ "$channel" != "" ]; then
    payload=$(echo $payload | jq --arg channel "$channel" '{"channel":$channel} + .')
fi

if [ "$dry" == 1 ]; then
    echo $payload | jq
    echo "Paste the above JSON text to https://api.slack.com/docs/messages/builder to preview your message."
    exit 1
fi

# post request
curl --header "Content-Type: application/json" \
    --request POST \
    --data "$payload" \
    $SLACK_WHURL
exit 0

