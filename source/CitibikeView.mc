import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CitibikeView extends WatchUi.View {
  private var _text as String;
  // private var _fetcher as CitibikeFetcher;

  function initialize() {
    View.initialize();
    // _fetcher = f;
    _text = "Loading...";
  }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

  function handleFetch(stations as Array<Dictionary>, error as String) {
    _text = "";
    Toybox.System.println("Got " + stations);
    for (var i = 0; i < stations.size(); i++) {
      if (i > 0) {
        _text += "\n";
      }
      var station = stations[i];
      _text += Abbreviate.abbreviatedName(station["name"], 15) + ": " + station["num_bikes_available"] + "-" + station["num_docks_available"] + "-" + station["num_ebikes_available"];
    }
    WatchUi.requestUpdate();
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {
    handleFetch(Storage.getValue("C"), Storage.getValue("E"));
    // _fetcher.onShow(method(:handleFetch));
  }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(dc.getWidth() / 6, 0.1 * dc.getHeight(), Graphics.FONT_XTINY, _text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
