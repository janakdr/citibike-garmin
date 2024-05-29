import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

class CitibikeFetcher {
    (:background)
    public static var internalStationType = "_internal_station_type";

    (:background)
    private var _contexts as Array<LocationFavorite>;

    (:background)
    static class LocationFavorite {
        (:background)
        var pickupStations as Dictionary<String, String>;
        (:background)
        var dropoffStations as Dictionary<String, String>;
        (:background)
        var stationOrder as Dictionary<String, Number>;
        (:background)
        var area as Zone;

      function initialize(pickups as Dictionary<String, String>,
              dropoffs as Dictionary<String, String>, order as Array<String>,
              a as Zone) {
          pickupStations = pickups;
          dropoffStations = dropoffs;
          stationOrder = {};
          for (var i = 0; i < order.size(); i++) {
              stationOrder[order[i]] = i;
          }
          area = a;
      }
    }

    (:background)
    static class ResponseContext {
        (:glance)
        var position as Toybox.Position.Location or Null;
        (:glance)
        var locationContext as LocationFavorite;

        function initialize(pos as Toybox.Position.Location or Null, lc as LocationFavorite) {
            position = pos;
            locationContext = lc;
        }
    }

    (:background)
    static class Zone {
        (:background)
        var bottom as Float;
        (:background)
        var top as Float;
        (:background)
        var left as Float;
        (:background)
        var right as Float;

      function initialize(b as Float, t as Float, l as Float, r as Float) {
        bottom = b;
        top = t;
        left = l;
        right = r;
      }

      (:background)
      function inside(degrees as Array<Double>) {
        return bottom <= degrees[0] && degrees[0] <= top && left <= degrees[1] && degrees[1] <= right;
      }
    }

  function initialize() {
      var c1 = new LocationFavorite({"66db3f62-0aca-11e7-82f6-3863bb44ef7c" => "M&S"}, {"66db88f5-0aca-11e7-82f6-3863bb44ef7c" => "L&W",
      "66dbea8d-0aca-11e7-82f6-3863bb44ef7c" => "D&W"}, ["M&S", "L&W", "D&W"],
      new Zone(40.69013, 40.69642, -73.98942, -73.97257));
      _contexts = [c1]; // new Array<LocationFavorite>[1];
  }

  (:background)
  function setCache(cache as Array<Dictionary<String, String or Number>> or Null,
      position as Toybox.Position.Location,
      error as String or Null) as Void {
      System.println("We got here with " + error);
      var newPosition = position.toDegrees();
      if (cache != null) {
          Storage.setValue("C", cache);
          Storage.deleteValue("E");
          Storage.setValue("T", Toybox.Time.now().value());
          Storage.setValue("P", newPosition);
          return;
      }
      var oldPosition = Storage.getValue("P");
      if (oldPosition == null || Math.pow((newPosition[0] - oldPosition[0]), 2) + Math.pow((newPosition[1] - oldPosition[1]), 2) > 1/15) {
          Storage.deleteValue("C");
          Storage.setValue("E", error);
          Storage.deleteValue("P");
          return;
      }
  }

  (:background)
  function onResponseNoFavorite(responseCode as Number,
          response as Dictionary or Null, responseContext as ResponseContext) as Void {
    if (responseCode != 200) {
      var error = responseCode + ": " + response;
      me.setCache(null, responseContext.position, error);
      return;
    }
    var dd = response["data"] as Dictionary<String, Array<Dictionary>>;
    var stations = dd["stations"];
    // _text = "";
    // for (var i = 0; i < stations.size(); i++) {
    //   var station = stations[i];
    //   if (i > 0) {
    //     _text += "\n";
    //   }
    //   _text += abbreviatedName(station["name"]) + ": " + station["num_bikes_available"] + "-" + station["num_docks_available"];
    // }
    me.setCache(stations, responseContext.position, null);
  }

  (:background)
  function testResponse(responseCode as Number, response as Dictionary or Null) as Void {
    System.println("Tested " + responseCode + ", " + response);
  }

  (:background)
  function onResponse(responseCode as Number,
          response as Dictionary or Null, responseContext as ResponseContext) as Void {
    if (responseCode != 200) {
      var error = responseCode + ": " + response;
      me.setCache(null, responseContext.position, error);
      return;
    }
    var dd = response["data"] as Dictionary<String, Array<Dictionary>>;
    var data = dd["stations"];
    var context = responseContext.locationContext;
    var reordered_stations = new [context.stationOrder.size()];
    for (var i = 0; i < data.size(); i++) {
      var station = data[i];
      if (context.pickupStations.hasKey(station["station_id"])) {
        station[internalStationType] = 1;
        station["name"] = context.pickupStations[station["station_id"]];
      } else {
        station[internalStationType] = 0;
      }
      if (context.dropoffStations.hasKey(station["station_id"])) {
        station[internalStationType] += 2;
        station["name"] = context.dropoffStations[station["station_id"]];
      }
      var ind = context.stationOrder[station["name"]];
      if (ind == null) {
        reordered_stations.add(station);
      } else {
        reordered_stations[ind] = station;
      }
    }
    me.setCache(reordered_stations, responseContext.position, null);
  }

  (:background)
  function onPosition(info as Toybox.Position.Info) as Void {
    var position = info.position;
    var favorite = null;
    if (position == null) {
      favorite = _contexts[0];
    } else {
      var degrees = position.toDegrees();
      for (var i = 0; i < _contexts.size(); i++) {
        if (_contexts[i].area.inside(degrees)) {
          favorite = _contexts[i];
          break;
        }
      }
    }
    var responseCallback;
    var degrees = position.toDegrees();
    var query = "?latitude=" + degrees[0] + "&longitude=" + degrees[1];
    if (favorite != null) {
      responseCallback = method(:onResponse);
      for (var k = 0; k < 2; k++) {
        var keys;
        if (k == 0) {
          keys = favorite.pickupStations.keys();
        } else {
          keys = favorite.dropoffStations.keys();
        }
        for (var i = 0; i < keys.size(); i++) {
          query += "&station=" + keys[i];
        }
      }
    } else {
        responseCallback = method(:onResponseNoFavorite);
    }
    var context = new ResponseContext(position, favorite);
    new MakeWebRequest(context, responseCallback).call("https://citibike-filter-la7kubovaa-uc.a.run.app" + query);
    // Communications.makeWebRequest(
    //     // "https://gbfs.lyft.com/gbfs/2.3/bkn/en/station_status.json", 
    //     // "https://8080-cs-84506072222-default.cs-us-east1-pkhd.cloudshell.dev",
    //     // "https://gbfs.citibikenyc.com/gbfs/2.3/gbfs.json",
    //     "https://citibike-filter-la7kubovaa-uc.a.run.app" + query,
    //     {}, options, responseCallback);
    // inf = Toybox.Time.Gregorian.info(Toybox.Time.now(), Toybox.Time.FORMAT_MEDIUM);
    // System.println(inf.hour + ":" + inf.min + ":" + inf.sec + " Made request");
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  (:background)
  function onShow() as Void {
    // Position.enableLocationEvents({:acquisitionType => Position.LOCATION_ONE_SHOT}, method(:onPosition));
    onPosition(Position.getInfo());
  }

    (:background)
    function fetch() as Void {
        System.println("Fetching");
        onShow();
    }
}


    var staticData = {
    "version" => 2.3,
    "data" => {
        "stations" => [
            {
                "num_docks_available" => 9,
                "name" => "Van Cortlandt Park S & Dickinson Ave",
                "station_id" => "1861681959015615218",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 3,
                "num_ebikes_available" => 12,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 1, "vehicle_type_id" => 1},
                    {"count" => 12, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784321,
                "num_bikes_available" => 13,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 16,
                "name" => "E Mosholu Pkwy & Van Cortlandt Ave E",
                "station_id" => "ffae66ec-7c16-436f-bd0a-eedf81d580e7",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 0,
                "num_ebikes_available" => 2,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 4, "vehicle_type_id" => 1},
                    {"count" => 2, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784385,
                "num_bikes_available" => 6,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 1,
                "name" => "Jerome Ave & E Mosholu Pkwy S",
                "station_id" => "e15a5c77-70b0-4b9d-9eae-f10ddda7d994",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 9,
                "num_ebikes_available" => 12,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 1, "vehicle_type_id" => 1},
                    {"count" => 12, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784384,
                "num_bikes_available" => 13,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 31,
                "name" => "W Mosholu Pkwy S & Sedgwick Ave",
                "station_id" => "ff1e98d3-ae7d-4c53-a531-1845bee1d346",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 3,
                "num_ebikes_available" => 1,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 2, "vehicle_type_id" => 1},
                    {"count" => 1, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784344,
                "num_bikes_available" => 3,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 9,
                "name" => "Grand Concourse & E Mosholu Pkwy S",
                "station_id" => "844c68cc-19f0-474a-86d3-4af170117aae",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 3,
                "num_ebikes_available" => 6,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 3, "vehicle_type_id" => 1},
                    {"count" => 6, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784393,
                "num_bikes_available" => 9,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 1,
                "name" => "Paul Ave & Mosholu Pkwy",
                "station_id" => "f001fac9-5f19-451e-a752-afde574a8c81",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 2,
                "num_ebikes_available" => 16,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 0, "vehicle_type_id" => 1},
                    {"count" => 16, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784396,
                "num_bikes_available" => 16,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 5,
                "name" => "E Mosholu Pkwy & E 204 St",
                "station_id" => "5f2766b0-362e-49e5-ab09-05e2c4b6f626",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 1,
                "num_ebikes_available" => 13,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 0, "vehicle_type_id" => 1},
                    {"count" => 13, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784360,
                "num_bikes_available" => 13,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 14,
                "name" => "Marion Ave & Mosholu Pkwy",
                "station_id" => "724aeecc-8c91-4afc-b97c-72a98de452c9",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 1,
                "num_ebikes_available" => 1,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 5, "vehicle_type_id" => 1},
                    {"count" => 1, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784403,
                "num_bikes_available" => 6,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 0,
                "name" => "Botanical Sq & Webster Ave",
                "station_id" => "9459fca8-b044-4ed1-8f2c-c5db11ba868f",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 2,
                "num_ebikes_available" => 1,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 29, "vehicle_type_id" => 1},
                    {"count" => 1, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784401,
                "num_bikes_available" => 30,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            },
            {
                "num_docks_available" => 5,
                "name" => "Van Cortlandt Park S & Gouverneur Ave",
                "station_id" => "1864606193814670106",
                "num_docks_disabled" => 0,
                "num_bikes_disabled" => 3,
                "num_ebikes_available" => 10,
                "is_renting" => 1,
                "is_returning" => 1,
                "is_installed" => 1,
                "vehicle_types_available" => [
                    {"count" => 7, "vehicle_type_id" => 1},
                    {"count" => 10, "vehicle_type_id" => 2}
                ],
                "last_reported" => 1707784378,
                "num_bikes_available" => 17,
                "num_scooters_available" => 0,
                "num_scooters_unavailable" => 0
            }
        ]
    },
    "last_updated" => 1707784429,
    "ttl" => 60
  };


