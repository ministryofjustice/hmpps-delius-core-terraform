let https = require("https");
let util = require("util");

exports.handler = function (event, context) {
    console.log(JSON.stringify(event, null, 2));

    const enabled = "${enabled}";
    const quietStart = +"${quiet_period_start_hour}", quietEnd = +"${quiet_period_end_hour}";

    const now = new Date(new Date().toLocaleString([], {timeZone: "Europe/London"})).getHours();
    const inQuietPeriod =
        quietStart <= quietEnd && (now >= quietStart && now < quietEnd) ||
        quietStart >  quietEnd && (now >= quietStart || now < quietEnd); // account for overnight periods (eg. 23:00-06:00)

    console.log("Alarms enabled:", enabled, ". Current hour:", now);
    if (!enabled || inQuietPeriod) { console.log("Dismissing notification."); return }

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

    let textMessage = icon_emoji + " " + (severity === "ok"? "*RESOLVED*": "*ALARM*")
        + "\n> Severity: " + severity.toUpperCase()
        + "\n> Environment: ${environment_name}"
        + "\n> Description: *" + eventMessage.AlarmDescription + "*"
        + "\n<https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#alarmsV2:alarm/" + eventMessage.AlarmName + "|View Details>";
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
        "username": "Delius-Core Alarm Notification",
        "text": textMessage,
        "icon_emoji": ":amazon:",
        "link_names": "1"
    }));
    req.end();
};