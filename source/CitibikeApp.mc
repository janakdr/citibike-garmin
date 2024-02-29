import Toybox.Application;
import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

(:background)
class CitibikeApp extends Application.AppBase {
    // (:background)
    (:glance)
    private static var _timerStarted = false as Boolean;

    (:background)
    var _fetcher as CitibikeFetcher;
    (:glance)
    var _glance as CitibikeGlance or Null;
    var _view as CitibikeView or Null;

    function initialize() {
        AppBase.initialize();
        // Storage.clearValues();
        _fetcher = new CitibikeFetcher();
        // System.println("Initialize");
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        // var lastFetch = Storage.getValue("T");
        // if (lastFetch == null || Time.now().subtract(new Time.Moment(lastFetch.toNumber())).value() > 60) {
        //     _fetcher.fetch();
        // }
        // getServiceDelegate()[0].onTemporalEvent();
    var inf = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_SHORT);
    System.println(inf.hour + ":" + inf.min + ":" + inf.sec + " initialize " + me);
    }

    // (:background)
    (:background)
    function callFetch() as Void {
        System.println("Fetching in pap");
        _fetcher.fetch();
    }

    function showView() as Void {
        System.println("Showing view");
        _view.onShow();
    }

    (:glance)
    function showGlance() as Void {
        System.println("Showing glance");
        _glance.onShow();
    }

    // onStart() is called on application start up
    (:background)
    function onStart(state as Dictionary?) as Void {
        System.println("Starting " + me);
    }

    // onStop() is called when your application is exiting
    (:background)
    function onStop(state as Dictionary?) as Void {
        var inf = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_SHORT);
        System.println(inf.hour + ":" + inf.min + ":" + inf.sec + " Stopping " + me);
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
        System.println("getting view " + me);
        // callFetch();
        _view = new CitibikeView(_fetcher);
        if (!_timerStarted) {
            System.println("timer started");
            _timerStarted = true;
            var callback = method(:callFetch);
            new Timer.Timer().start(callback, 30000, true);
            // callFetch();
        }
        new Timer.Timer().start(method(:showView), 30500, true);
        return [ _view ];
    }

    (:glance)
    function getGlanceView() {
        System.println("Glance view " + me);
        callFetch();
        if (!_timerStarted) {
            System.println("timer started");
            _timerStarted = true;
            var callback = method(:callFetch);
            new Timer.Timer().start(callback, 30000, true);
            // callFetch();
        }
        _glance = new CitibikeGlance();
        new Timer.Timer().start(method(:showGlance), 30500, true);
        return [ _glance ];
    }

    (:background)
    public function getServiceDelegate() {
        return [new CitibikeServiceDelegate(_fetcher)];
    }

    (:background)
    function getApp() as CitibikeApp {
        var callback = method(:callFetch);
        System.println("Calling fetch in getApp " + me);
        callFetch();
        new Timer.Timer().start(callback, 30000, true);
        return Application.getApp() as CitibikeApp;
    }
}
