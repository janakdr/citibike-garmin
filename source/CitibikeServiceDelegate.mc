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
        System.println("Fetching temporally");
        _fetcher.fetch();
    }
}

