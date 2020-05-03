slack-post
=========

Simple slack post interface from terminal with webhook.

Installing
----------
### Dependency
This script use `jq` command to modify json text.
Install`jq` if you don't have `jq`.
```bash
sudo apt install jq
```

### Setup Slack Incomming Webhook
Follow the official configuration manual below to obtain the webhook URL.
https://api.slack.com/messaging/webhooks#getting_started

Webhook URL looks something like this: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`,
and export the URL to `$SLACK_WHURL` with the command below.

```bash
export $SLACK_WHURL=https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

Copy `slack_post.sh` to your local directory and give the file execute permission.
```bash
chmod +x slack_post.sh
```

Send message
------------
By default, this script will post to default channel selected when you generate
webhook URL.
You can change default channel from here.
https://slack.com/apps/A0F7XDUAZ

1. Send message
    ```bash
    ./slack_post.sh -t 'Hello from terminal!'
    ```
2. Send a message received in a pipe.
    ```bash
    echo 'Message via pipe' | ./slack_post.sh
    ```
3. Customize message
    ```bash
    # Send different channel
    ./slack_post.sh --channel #random --username 'The Living Dead' --icon_emoji ':male-zombie:'
    ```

If you want to post full-customized message, generate json text and post it with following command.
```bash
curl -X POST -H 'Content-type: application/json' --data '{"text":"Done!"}' $SLACK_WHURL
```
