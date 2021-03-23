let https = require("https");
let util = require("util");
let AWS = require('aws-sdk');
let ssm = new AWS.SSM({ region: process.env.REGION });

exports.handler = function (event, context) {
    console.log(JSON.stringify(event, null, 2));

    const now = new Date(new Date().toLocaleString([], {timeZone: "Europe/London"})).getHours();
    const quietStart = +process.env.QUIET_PERIOD_START_HOUR, quietEnd = +process.env.QUIET_PERIOD_END_HOUR;
    const inQuietPeriod =
        quietStart <= quietEnd && (now >= quietStart && now < quietEnd) ||
        quietStart >  quietEnd && (now >= quietStart || now < quietEnd); // account for overnight periods (eg. 23:00-06:00)

    console.log("Alarms enabled:", process.env.ENABLED, ". Current hour:", now);
    if (process.env.ENABLED !== "true" || inQuietPeriod) { console.log("Dismissing notification."); return }

    const eventMessage = JSON.parse(event.Records[0].Sns.Message);
    let severity = eventMessage.AlarmName.split("--")[1];    // could we use tags for this??
    if (eventMessage.NewStateValue === "OK") severity = "ok";

    if (eventMessage.NewStateValue === "INSUFFICIENT_DATA"
        || (eventMessage.NewStateValue === "OK" && eventMessage.OldStateValue === "INSUFFICIENT_DATA")) {
        console.log("Ignoring 'INSUFFICIENT_DATA' notification");
        return;
    }

    let icon_emoji = ":question:";
    if (severity === "ok")       icon_emoji = ":yep:";
    if (severity === "warning")  icon_emoji = ":warning:";
    if (severity === "critical") icon_emoji = ":siren:";
    if (severity === "fatal")    icon_emoji = ":alert:";

    let textMessage = icon_emoji + " " + (severity === "ok" ? "*RESOLVED*" : "*ALARM*")
        + "\n> Severity: " + severity.toUpperCase()
        + "\n> Environment: " + process.env.ENVIRONMENT_NAME
        + "\n> Description: *" + eventMessage.AlarmDescription + "*"
        + "\n<https://" + process.env.REGION + ".console.aws.amazon.com/cloudwatch/home?region=" + process.env.REGION + "#alarmsV2:alarm/" + eventMessage.AlarmName + "|View Details>";
    // textMessage += "\n```" + JSON.stringify(eventMessage, null, "\t") + "```\n\n";

    ssm.getParameter({ Name: process.env.SLACK_TOKEN, WithDecryption: true }, function(err, data) {
        if (err) {
            console.log("Unable to get access token for Slack", process.env.SLACK_TOKEN, err);
            return context.fail("Unable to get access token for Slack");
        }

        const req = https.request({
            method: "POST",
            hostname: "slack.com",
            port: 443,
            path: "/api/chat.postMessage",
            headers: {
                "Authorization": "Bearer " + data.Parameter.Value,
                "Content-Type": "application/json"
            }
        }, function (res) {
            res.setEncoding("utf8");
            res.on("data", function (chunk) {
                console.log("Response received", chunk)
                return context.done(null)
            });
        });
        req.on("error", function (e) {
            console.log("Unable to post message to Slack", e);
            return context.fail("Unable to post message to Slack");
        });
        req.write(util.format("%j", {
            "channel": "# " + process.env.SLACK_CHANNEL,
            "username": "Delius-Core Alarm Notification",
            "text": textMessage,
            "icon_emoji": ":amazon:",
            "link_names": "1"
        }));
        req.end();
    });
};