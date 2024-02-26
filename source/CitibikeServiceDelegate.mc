import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

(:background)
class CitibikeServiceDelegate extends System.ServiceDelegate {
    private var _fetcher as CitibikeFetcher;

    function initialize(fetcher as CitibikeFetcher) {
        System.ServiceDelegate.initialize();
        me._fetcher = fetcher;
    }

    function onTemporalEvent() as Void {
        var lastFetch = Storage.getValue("T");
        if (lastFetch == null || (Time.now().subtract(new Time.Moment(lastFetch.toNumber())).value() > 60)) {
            _fetcher.fetch();
        }
    }
}

