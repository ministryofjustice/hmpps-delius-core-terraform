var https = require("https");
var util = require("util");

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));

    const enabled = "${enabled}";
    const quietStart = +"${quiet_period_start_hour}", quietEnd = +"${quiet_period_end_hour}";

    const now = new Date(new Date().toLocaleString("en-GB", {timeZone: "Europe/London"})).getHours();
    const inQuietPeriod =
        quietStart <= quietEnd && (now >= quietStart && now < quietEnd) ||
        quietStart >  quietEnd && (now >= quietStart || now < quietEnd); // account for overnight periods (eg. 23:00-06:00)

    if (!enabled || inQuietPeriod) {
        console.log("Alarms disabled, dismissing notification.");
        return;
    }

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
        + "\n> Environment: ${environment_name}"
        + "\n> Description: *" + eventMessage.detail.jobName + " " + eventMessage.detail.status.toLowerCase() + " with message '" + eventMessage.detail.statusReason + "'*"
        + "\n <https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logsV2:log-groups/log-group/$252Faws$252Fbatch$252Fjob|Cloudwatch Logs>";

   //Only send for specific events (SUCCEEDED, FAILED)
   if (sendSlackNotification) {
      console.log("Sending slack Notification..");
      const req = https.request({
          method: "POST",
          hostname: "hooks.slack.com",
          port: 443,
          path: "/services/T02DYEB3A/BGJ1P95C3/f1MBtQ0GoI6kbGUztiSpkOut"
      }, function (res) {
          res.setEncoding("utf8");
          res.on("data", function (chunk) { return context.done(null) });
      });
      req.on("error", function (e) {
          return console.log("problem with request: " + e.message);
      });
      req.write(util.format("%j", {
          "channel": "# ${channel}",
          "username": "Delius-Core Batch Notification",
          "text": textMessage,
          "icon_emoji": ":amazon:",
          "link_names": "1"
      }));
      req.end();
   }
   else {
       console.log("Skipping sending slack notification as this is for an event we don't notify on (RUNNABLE, STARTING,etc)..")
   }
};
