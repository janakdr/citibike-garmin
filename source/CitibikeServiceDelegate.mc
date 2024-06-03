import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

(:background)
class CitibikeServiceDelegate extends System.ServiceDelegate {
    private var _fetcher as CitibikeFetcher;

    function initialize(fetcher as CitibikeFetcher) {
        System.ServiceDelegate.initialize();
        me._fetcher = fetcher;
    }

    function onTemporalEvent() as Void {
        var lastFetch = Storage.getValue("L");
        var cutoff = new Time.Moment(lastFetch.toNumber()).add(new Time.Duration(120));
        // var diff = new Time.Duration(3000);
        System.println("Fetching temporally");
        _fetcher.fetch();
        if (cutoff.lessThan(Time.now())) {
            System.println("Stopping temporally" + cutoff + ", " + Time.now());
            Background.deleteTemporalEvent();
            Storage.deleteValue("L");
        }
    }
}

