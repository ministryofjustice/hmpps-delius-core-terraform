var https = require("https");
var util = require("util");

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));
    const londonTime = new Date().toLocaleString("en-GB", {timeZone: "Europe/London"});
    const now = new Date(londonTime).getHours();
    if (now >= +"${quiet_period_start_hour}" && now < +"${quiet_period_end_hour}") {
        console.log("In quiet period, dismissing alarm");
        return;
    }

    let environment_name = process.env.ENVIRONMENT_NAME;
    console.log("environment_name:" + environment_name);
    
    const eventMessage = JSON.parse(event.Records[0].Sns.Message);
    console.log(JSON.stringify(eventMessage.detail, null, 2));
    
    let sendSlackNotification = false;
    let severity = "ok";
    let icon_emoji = ":question:";
    
    switch(eventMessage.detail.status) {
      case "SUCCEEDED":
        severity = "ok";
        icon_emoji = ":yep:";
        sendSlackNotification = true;
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
    
    console.log("severity:" + severity);
    console.log("icon_emoji:" + icon_emoji);
    console.log("sendSlackNotification:" + sendSlackNotification);
    
    // let jobId = eventMessage.detail.jobId;
    // let jobName = eventMessage.detail.jobName;
    // let jobQueue = eventMessage.detail.jobQueue;
    let logsPath = "https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logsV2:log-groups/log-group/$252Faws$252Flambda$252F" + environment_name + "-notify-delius-core-slack-channel-batch";
    let statusReason = eventMessage.detail.statusReason;
    // console.log("jobId:" + jobId);
    // console.log("jobName:" + jobName);
    // console.log("jobQueue:" + jobQueue);
    // console.log("logsPath:" + logsPath);
    // console.log("statusReason:" + statusReason);
    
    let textMessage = icon_emoji + " " + (severity === "ok"? "*RESOLVED*": "*ALARM*")
        + "\n> Severity: " + severity.toUpperCase()
        + "\n> Status: " + eventMessage.detail.status
        + "\n> Environment: " + environment_name
        + "\n> Description: *" + statusReason + "*"
        + "\n " + logsPath;
    // textMessage += "\n```" + JSON.stringify(eventMessage, null, "\t") + "```\n\n";
    console.log(textMessage);
   
   //Only send for specific events (SUCCEEDED, FAILED)
   if(sendSlackNotification == true) {
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
          "channel": "# delius-alerts-deliuscore-nonprod",
          "username": "AWS SNS via Lambda :: DSS Offloc AWS Batch Alarms",
          "text": textMessage,
          "icon_emoji": ":amazon:",
          "link_names": "1"
      }));
      req.end();
   }
   else {
    console.log("Skipping sending slack notification as this is for an event we don't notify on (RUNNABLE, STARTING,etc)..");
   }
};
