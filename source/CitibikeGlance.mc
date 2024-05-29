import Toybox.Application.Storage;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.System;

(:glance)
class CitibikeGlance extends WatchUi.GlanceView {
  (:glance)
  private var _station_status as Array<StationStatus>;

  function initialize() {
      GlanceView.initialize();
      _station_status = [];
      System.println("Initialized glance " + me);
  }

    (:glance)
    class StationStatus {
        var name as String;
        var bikes as Number or Null;
        var docks as Number or Null;
        var ebikes as Number or Null;

        function initialize(name) {
          me.name = name;
        }
    }

  // Load your resources here
  (:glance)
  function onLayout(dc as Dc) as Void {
      // setLayout(Rez.Layouts.MainLayout(dc));
  }

  (:glance)
  function handleFetch(stations as Array<Dictionary<String, String or Number>>, error as String) as Void {
    _station_status = [] as Array<StationStatus>;
    if (error != null) {
      _station_status = [new StationStatus(error)];
      return;      
    }
    if (stations == null) {
      _station_status = [new StationStatus("Null....")];
      return;
    }
    var foundPickup = false;
    var foundDropoff = false;
    for (var i = 0; i < stations.size(); i++) {
      var station = stations[i];
      var item = new StationStatus(station["name"]);
      var type;
      if (station.hasKey(CitibikeFetcher.internalStationType)) {
        type = station[CitibikeFetcher.internalStationType];
      } else {
        type = 3;
      }
      if (type & 1 == 0 && foundDropoff) {
        continue;
      }
      if (type & 2 == 0 && foundPickup) {
        continue;
      }
      if (type & 1 != 0) {
        if (station["num_bikes_available"] > 2) {
          foundPickup = true;
        }
        item.bikes = station["num_bikes_available"];
        item.ebikes = station["num_ebikes_available"];
      }
      if (type & 2 != 0) {
        if (station["num_docks_available"] > 2) {
          foundDropoff = true;
        }
        item.docks = station["num_docks_available"];
      }
      _station_status.add(item);
      if (foundPickup && foundDropoff) {
        break;
      }
    }
    System.println("Got here with " + _station_status);
    WatchUi.requestUpdate();
    System.println("Why no update");
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  (:glance)
  function onShow() as Void {
    System.println("Shwoing glance " + me);
    handleFetch(Storage.getValue("C"), Storage.getValue("E"));
    // _fetcher.onShow(method(:handleFetch));
  }

  // Update the view
  (:glance)
  function onUpdate(dc as Dc) as Void {
      Toybox.System.println("Updating glance " + me);
      dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
      dc.clear();
      if (_station_status.size() == 0) {
        dc.drawText(0, 0.1 * dc.getHeight(), Graphics.FONT_XTINY, "Loading", Graphics.TEXT_JUSTIFY_LEFT);
        return;
      }
      var maxChar = 15;
      var names = [];
      for (var i = 0; i < _station_status.size(); i++) {
        names.add(_station_status[i].name);
      }
      var cutoffAndSurplus = Abbreviate.findFairAbbreviationLength(names, maxChar);

      var cutoff = cutoffAndSurplus[0];
      var surplus = cutoffAndSurplus[1];
      var startX = 0;
      var startY = 0.1 * dc.getHeight();
      for (var i = 0; i < _station_status.size(); i++) {
        var station = _station_status[i];
        var name = station.name;
        if (name.length() > cutoff) {
          var c = cutoff;
          if (surplus > 0) {
            c++;
            surplus--;
          }
          name = Abbreviate.abbreviatedName(name, c);
        }
        var background;
        if (station.ebikes != null) {
          var scalar = Abbreviate.min(station.ebikes, 5) / 5.0;
          background = scalar * 0xFFFFFF;
        } else {
          background = 0x000000;
        }
        var len;
        if (station.bikes == null || station.docks == null) {
          len = name.length();
        } else {
          len = name.length() / 2;
          if (len == 0 && station.bikes != null) {
            len = 1;
          }
        }
        var start = 0;
        if (station.bikes != null) {
          dc.setColor(colorForNumber(station.bikes), background);
          var text = name.substring(start, len);
          dc.drawText(startX, startY, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
          startX += dc.getTextWidthInPixels(text, Graphics.FONT_XTINY);
          start = len;
        }
        if (station.docks != null) {
          dc.setColor(colorForNumber(station.docks), background);
          var text = name.substring(start, null);
          dc.drawText(startX, startY, Graphics.FONT_XTINY, text, Graphics.TEXT_JUSTIFY_LEFT);
          startX += dc.getTextWidthInPixels(text, Graphics.FONT_XTINY);
        }
        if (i < _station_status.size() - 1) {
          dc.setColor(0xFFFFFF, 0x000000);
          dc.drawText(startX, startY, Graphics.FONT_XTINY, ",", Graphics.TEXT_JUSTIFY_LEFT);
          startX += dc.getTextWidthInPixels(",", Graphics.FONT_XTINY);
        }
      }
      // var pretext = "hi";
      // var width = dc.getTextWidthInPixels(pretext, Graphics.FONT_XTINY);
      // dc.drawText(dc.getWidth() / 6, 0.1 * dc.getHeight(), Graphics.FONT_XTINY, pretext, Graphics.TEXT_JUSTIFY_LEFT);
      // dc.drawText(width + dc.getWidth() / 6, 0.1 * dc.getHeight(), Graphics.FONT_XTINY, _text, Graphics.TEXT_JUSTIFY_LEFT);
  }

  (:glance)
  function colorForNumber(num as Number or Null) as Number {
    if (num == null) {
      return 0x0000FF;
    }
    if (num > 3) {
      return (0xFF * Abbreviate.min(num, 8) / 8) << 8;
    }
    if (num > 1) {
      return 0x00FFFF * num / 4;
    }
    return (0xFF * (2 - num) / 2) << 16;
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from
  // memory.
  (:glace)
  function onHide() as Void {
    System.println("Hiding " + me);
  }

}
