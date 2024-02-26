import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:glance)
class CitibikeApp extends Application.AppBase {
    // (:background)
    (:glance)
    private static var _timerStarted = false as Boolean;

    (:glance)
    var _fetcher as CitibikeFetcher;
    function initialize() {
        AppBase.initialize();
        // Storage.clearValues();
        _fetcher = new CitibikeFetcher();
        // System.println("Initialize");
        // if (!_timerStarted) {
        //     System.println("timer started");
        //     _timerStarted = true;
        //     // var callback = method(:callFetch);
        //     // new Timer.Timer().start(callback, 30000, true);
        //     // callFetch();
        //     Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        //                 System.println("restier");

        // }
        // System.println("timer started");
        // var lastFetch = Storage.getValue("T");
        // if (lastFetch == null || Time.now().subtract(new Time.Moment(lastFetch.toNumber())).value() > 60) {
        //     _fetcher.fetch();
        // }
        // getServiceDelegate()[0].onTemporalEvent();
    }

    // (:background)
    (:glance)
    function callFetch() as Void {
        System.println("Fetching in pap");
        _fetcher.fetch();
    }
    // onStart() is called on application start up
    (:glance)
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    (:glance)
    function onStop(state as Dictionary?) as Void {
        System.println("Stopping " + me);
    }

    // function onUpdate(dc) {
    //   requestCitibikeData();
    // }

    // function requestCitibikeData() {
    //   Communications.makeWebRequest("http://janak.org", {}, {}, )
    // }

    // function onWebRequestResponse(responseCode, data) {
    //     if (responseCode == 200) {
            
    //     } else {
    //         System.println("Web request failed: " + responseCode);
    //     }
    // }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        callFetch();
        return [ new CitibikeView() ];
    }

    (:glance)
    function getGlanceView() {
        System.println("Starting " + me);
        callFetch();
        return [ new CitibikeGlance() ];
    }

    public function getServiceDelegate() {
        return [new CitibikeServiceDelegate(_fetcher)];
    }

    (:glance)
    function getApp() as CitibikeApp {
        var callback = method(:callFetch);
        System.println("Calling fetch");
        callFetch();
        new Timer.Timer().start(callback, 30000, true);
        return Application.getApp() as CitibikeApp;
    }
}

    (:glance)
    function getApp() as CitibikeApp {
        System.println("Free function");
        return Application.getApp() as CitibikeApp;
    }
