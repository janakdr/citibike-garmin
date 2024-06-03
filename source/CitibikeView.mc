import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class CitibikeView extends WatchUi.View {
  private var _error_text as String;
  private var _text as Array<String>;
  private var _fetcher as CitibikeFetcher;
  private var _xCoords as Array<String>;
  private var _charCounts as Array<String>;
  private var _heightOffset as Number or Null;
  private var _textHeight as Number or Null;
  private var _pixelsPerChar as Number or Null;
  private static var _minChars as Number = 22;

  function initialize(fetcher as CitibikeFetcher) {
    View.initialize();
    me._fetcher = fetcher;
    me._xCoords = new Array<String>();
    me._charCounts = new Array<String>();
    _text = "Loading...";
    Toybox.System.println("Initialized view " + me);
  }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
        var textSize = dc.getTextDimensions("W", Graphics.FONT_XTINY);
        me._textHeight = textSize[1];
        var pixelsPerChar = textSize[0];
        var pixelsForMinCharBy2 = pixelsPerChar *  22 / 2;
        var radius2 = Math.pow(dc.getHeight() / 2, 2);
        var widthBy2 = dc.getWidth() / 2;
        var height = Math.sqrt(radius2 - Math.pow(pixelsForMinCharBy2, 2))
        var me._heightOffset = dc.getHeight() - height;
        while (true) {
          var width = Math.sqrt(radius2 - Math.pow(height, 2));
          if (width < pixelsForMinCharBy2) {
            break;
          }
          me._xCoords.add(widthBy2 - width);
          me._charCounts.add(2 * width / pixelsPerChar)
          height = height - me._textHeight;
        }
    }

  function handleFetch(stations as Array<Dictionary>, error as String) {
    me._error_text = "";
    me._text = new Array<String>();
    if (stations == null) {
      me._error_text = error;
      return;
    }
    for (var i = 0; i < stations.size(); i++) {
      if (i >= me._xCoords.size()) {
        // Watch display can't show more than 9 lines.
        break;
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
        _fetcher.fetch();
        // Start background thread. It will be ended after 40 minutes.
        Storage.setValue("L", Toybox.Time.now().value());
        Background.registerForTemporalEvent(new Time.Duration(5 * 60));
        Toybox.System.println("Done with fetcher view " + me);
        handleFetch(Storage.getValue("C"), Storage.getValue("E"));
        Toybox.System.println("Done with handle " + me);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        Toybox.System.println("Updating view " + me);
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
