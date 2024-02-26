import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.System;

class CitibikeFetcher {
    (:glance)
    public static var internalStationType = "_internal_station_type";

    (:background)
    private var _contexts as Array<LocationFavorite>;

    (:glance)
    static class LocationFavorite {
        (:glance)
        var pickupStations as Dictionary<String, String>;
        (:glance)
        var dropoffStations as Dictionary<String, String>;
        (:glance)
        var stationOrder as Dictionary<String, Number>;
        (:glance)
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

    (:glance)
    static class ResponseContextWithFavorite {
        (:glance)
        var locationContext as LocationFavorite;
        (:glance)
        var callback as Method(stations as Array<Dictionary> or Null, error as String or Null);

        function initialize(lc as LocationFavorite, c as Method(stations as Array<Dictionary> or Null, error as String or Null)) {
            locationContext = lc;
            callback = c;
        }
    }

    (:glance)
    static class Zone {
        (:glance)
        var bottom as Float;
        (:glance)
        var top as Float;
        (:glance)
        var left as Float;
        (:glance)
        var right as Float;

      function initialize(b as Float, t as Float, l as Float, r as Float) {
        bottom = b;
        top = t;
        left = l;
        right = r;
      }

      (:glance)
      function inside(degrees as Array<Double>) {
        return bottom <= degrees[0] && degrees[0] <= top && left <= degrees[1] && degrees[1] <= right;
      }
    }

    private static var staticData = {
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

  function initialize() {
      var c1 = new LocationFavorite({"66db3f62-0aca-11e7-82f6-3863bb44ef7c" => "M&S"}, {"66db88f5-0aca-11e7-82f6-3863bb44ef7c" => "W&L",
      "66dbea8d-0aca-11e7-82f6-3863bb44ef7c" => "W&D"}, ["M&S", "W&L", "W&D"],
      new Zone(40.69013, 40.69642, -73.98942, -73.97257));
      _contexts = [c1]; // new Array<LocationFavorite>[1];
  }

  (:glance)
  static function onResponseNoFavorite(responseCode as Number,
          response as Dictionary, callback) as Void {
    if (responseCode != 200) {
      callback.invoke(null, responseCode + ": " + response);
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
    callback.invoke(stations, null);
  }

  (:glance)
  static function onResponse(responseCode as Number,
          response as Dictionary, responseContext as ResponseContextWithFavorite) as Void {
    if (responseCode != 200) {
      responseContext.callback.invoke(null, responseCode + ": " + response);
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
        Toybox.System.error("Null index for " + station);
      } else {
        reordered_stations[ind] = station;
      }
    }
    responseContext.callback.invoke(reordered_stations, null);
  }

  (:glance)
  function onPosition(info as Toybox.Position.Info, callback) as Void {
    System.println("positioning");
    var position = info.position;
    var context = null;
    if (position == null) {
      context = _contexts[0];
    } else {
      var degrees = position.toDegrees();
      for (var i = 0; i < _contexts.size(); i++) {
        if (_contexts[i].area.inside(degrees)) {
          context = _contexts[i];
          break;
        }
      }
    }
    var options = {                                             // set the options
        :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :headers => {"Accept-Encoding" => "gzip"},
    };
    var responseCallback;
    var query;
    if (context != null) {
      responseCallback = method(:onResponse);
      options[:context] = new ResponseContextWithFavorite(context, callback);
      query = null;
      for (var k = 0; k < 2; k++) {
        var keys;
        if (k == 0) {
          keys = context.pickupStations.keys();
        } else {
          keys = context.dropoffStations.keys();
        }
        for (var i = 0; i < keys.size(); i++) {
          if (query == null) {
            query = "?";
          } else {
            query += "&";
          }
          query += "station=" + keys[i];
        }
      }
    } else {
      responseCallback = method(:onResponseNoFavorite);
      options[:context] = callback;
      var degrees = position.toDegrees();
      query = "?latitude=" + degrees[0] + "&longitude=" + degrees[1];
      // onResponseNoFavorite(200, staticData, callback);
    }
    System.println("https://citibike-filter-la7kubovaa-uc.a.run.app" + query);
    Communications.makeWebRequest(
        // "https://gbfs.lyft.com/gbfs/2.3/bkn/en/station_status.json", 
        // "https://8080-cs-84506072222-default.cs-us-east1-pkhd.cloudshell.dev",
        // "https://gbfs.citibikenyc.com/gbfs/2.3/gbfs.json",
        "https://citibike-filter-la7kubovaa-uc.a.run.app" + query,
        {}, options, responseCallback);
  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  (:glance)
  function onShow(callback) as Void {
    // Position.enableLocationEvents({:acquisitionType => Position.LOCATION_ONE_SHOT}, method(:onPosition));
    onPosition(Position.getInfo(), callback);
  }

    (:background)
    function setCache(cache as Array<Dictionary<String, String or Number>>, error as String) as Void {
        System.println("Setting cache " + cache.size());
        Storage.setValue("T", Toybox.Time.now().value());
        if (cache != null) {
            Storage.setValue("C", cache);
            Storage.deleteValue("E");
        } else {
            Storage.deleteValue("C");
            Storage.setValue("E", error);
        }
    }

    (:background)
    function fetch() as Void {
        System.println("Fetching");
        onShow(method(:setCache));
    }
}

