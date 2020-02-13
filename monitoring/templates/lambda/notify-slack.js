var https = require("https");
var util = require("util");

exports.handler = function(event, context) {
    console.log(JSON.stringify(event, null, 2));
    const now = new Date().getHours();
    if (now >= +"${quiet_period_start_hour}" && now < +"${quiet_period_end_hour}") {
        console.log("In quiet period, dismissing alarm");
        return;
    }

    const eventMessage = JSON.parse(event.Records[0].Sns.Message);
    let severity = eventMessage.AlarmName.split("--")[1];    // could we use tags for this??
    if (eventMessage.NewStateValue === "OK") severity = "ok";
    if (eventMessage.NewStateValue === "INSUFFICIENT_DATA") severity = "insufficient data";

    let icon_emoji = ":question:";
    if (severity === "ok")       icon_emoji = ":yep:";
    if (severity === "warning")  icon_emoji = ":warning:";
    if (severity === "critical") icon_emoji = ":siren:";
    if (severity === "fatal")    icon_emoji = ":alert:";

    let textMessage = icon_emoji + " " + (severity === "ok"? "*RESOLVED*": "*ALARM*")
        + "\n> Severity: " + severity.toUpperCase()
        + "\n> Environment: ${environment_name}"
        + "\n> Description: *" + eventMessage.AlarmDescription + "*"
        + "\nhttps://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#alarmsV2:alarm/" + eventMessage.AlarmName;
    // textMessage += "\n```" + JSON.stringify(eventMessage, null, "\t") + "```\n\n";

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
        "username": "AWS SNS via Lambda :: Alarm notification",
        "text": textMessage,
        "icon_emoji": ":amazon:",
        "link_names": "1"
    }));
    req.end();
};