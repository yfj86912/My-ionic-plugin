
var xunfeiPlugin = {};

xunfeiPlugin.initAppid = function (okCb, failCb) {
    console.log("plugin JS called");
    cordova.exec(okCb, failCb,
        "xunfeiPlugin", // service
        "initAppid", // action name
            [] // a blank option
    );
    console.error("JS call ended");
};

xunfeiPlugin.tryListening = function (okCb, failCb) {
    console.log("CY tryListening")
    cordova.exec(okCb, failCb,
        "xunfeiPlugin", // service
        "initMyRecognizer", // action name
        []
    );
};

xunfeiPlugin.trySpeak = function (okCb, failCb, opt) {
    cordova.exec(okCb, failCb,
        "xunfeiPlugin", // service
        "stop", // action name
        opt
    );
};

module.exports = xunfeiPlugin;
