let https = require("https");
let util = require("util");
let AWS = require('aws-sdk');
let ssm = new AWS.SSM({ region: process.env.REGION });

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

    const now = new Date(new Date().toLocaleString("en-GB", {timeZone: "Europe/London"})).getHours();
    const quietStart = +process.env.QUIET_PERIOD_START_HOUR, quietEnd = +process.env.QUIET_PERIOD_END_HOUR;
    const inQuietPeriod =
        quietStart <= quietEnd && (now >= quietStart && now < quietEnd) ||
        quietStart >  quietEnd && (now >= quietStart || now < quietEnd); // account for overnight periods (eg. 23:00-06:00)

    console.log("Alarms enabled:", process.env.ENABLED, ". Current hour:", now);
    if (process.env.ENABLED !== "true" || inQuietPeriod) { console.log("Dismissing notification."); return }

    const eventMessage = JSON.parse(event.Records[0].Sns.Message);
    let sendSlackNotification, severity, icon_emoji;
    switch(eventMessage.detail.status) {
      case "SUCCEEDED":
        severity = "ok";
        icon_emoji = ":yep:";
        sendSlackNotification = false;
        break;
      case "FAILED":
        severity = "critical";
        icon_emoji = ":siren:";
        sendSlackNotification = true;
        break;
      default:
        severity = "ok";
        icon_emoji = ":yep:";
        sendSlackNotification = false;
    }

    let textMessage = icon_emoji + " " + (severity === "ok"? "*SUCCEEDED*": "*ALARM*")
        + "\n> Severity: " + severity.toUpperCase()
        + "\n> Status: " + eventMessage.detail.status
        + "\n> Environment: " + process.env.ENVIRONMENT_NAME
        + "\n> Description: *" + eventMessage.detail.jobName + " " + eventMessage.detail.status.toLowerCase() + " with message '" + eventMessage.detail.statusReason + "'*"
        + "\n <https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logsV2:log-groups/log-group/$252Faws$252Fbatch$252Fjob|Cloudwatch Logs>";

   //Only send for specific events (SUCCEEDED, FAILED)
   if (sendSlackNotification) {
       console.log("Sending slack Notification..");

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
               "username": "Delius-Core Batch Notification",
               "text": textMessage,
               "icon_emoji": ":amazon:",
               "link_names": "1"
           }));
           req.end();
       });
   }
   else {
       console.log("Skipping sending slack notification as this is for an event we don't notify on (RUNNABLE, STARTING,etc)..")
   }
};
