import Toybox.Lang;

(:glance)
class Abbreviate {
    private static var preTerminalTransformations = {"St" => "", "Av" => "", "Ave" => "", "Pl" => "",
    "Plaza" => "", "Pkwy" => "", "Park" => ""} as Dictionary<String, String>;
    private static var terminalSegments = {"&" => true, "N" => true,
    "S" => true, "E" => true, "W" => true} as Dictionary<String, Boolean>;

    // Function to swap elements in an array
    private static function swap(arr as Array, i, j) {
        var temp = arr[i];
        arr[i] = arr[j];
        arr[j] = temp;
    }

    // Partition function
    private static function partition(arr as Array, low as Number, high as Number) {
        // Choose the rightmost element as pivot
        var pivot = arr[high];
        var i = (low - 1);

        for (var j = low; j < high; j++) {
            // If current element is smaller than or equal to pivot
            if (arr[j] <= pivot) {
                i++; // Increment index of smaller element
                swap(arr, i, j);
            }
        }
        swap(arr, i + 1, high);
        return (i + 1);
    }

    // The main function that implements QuickSort
    // arr[] --> Array to be sorted,
    // low  --> Starting index,
    // high  --> Ending index
    static function sort(arr as Array, low as Number, high as Number) {
        if (low < high) {
            // pi is partitioning index, arr[pi] is now at right place
            var pi = partition(arr, low, high);

            // Recursively sort elements before partition and after partition
            sort(arr, low, pi - 1);
            sort(arr, pi + 1, high);
        }
    }

    static function findFairAbbreviationLength(arr as Array<String>, maxLength as Number) as [Number, Number] {
        var lengths = [] as Array<Number>;
        for (var i = 0; i < arr.size(); i++) {
            lengths.add(arr[i].length());
        }
        var sz = lengths.size();
        sort(lengths, 0, sz - 1);

        var currentLen = 0;
        var cutoff = 0;
        var ind = 0;
        var tail = sz - ind;
        while (currentLen < maxLength && ind < sz) {
            var len = lengths[ind];
            if (len <= cutoff) {
              ind++;
              continue;
            }
            tail = sz - ind;
            ind++;
            var allowed = (maxLength - currentLen) / tail;
            var newCutoff = min(len, allowed + cutoff);
            if (newCutoff == cutoff) {
              break;
            }
            currentLen += (newCutoff - cutoff) * tail;
            cutoff = newCutoff;
        }
        return [cutoff, maxLength - currentLen];
    }

    static function fairlyAbbreviate(arr as Array<String>, len as Number) as Void {
        var cutoffAndSurplus = findFairAbbreviationLength(arr, len);
        Toybox.System.println("Got abbrev " + cutoffAndSurplus + " for " + arr + " and " + len);
        for (var i = 0; i < arr.size(); i++) {
            if (arr[i].length() > cutoffAndSurplus[0]) {
                var c = cutoffAndSurplus[0];
                if (cutoffAndSurplus[1] > 0) {
                    c++;
                    cutoffAndSurplus[1]--;
                }
                arr[i] = arr[i].substring(0,c);
            }
        }
    }

    static function abbreviatedName(name as String, len as Number) as String {
        var segments = [] as Array<String>;
        var start = 0;
        var ind  = name.find(" ");
        while (ind != null) {
          segments.add(name.substring(start, start + ind));
          start += ind + 1;
          ind = name.substring(start, null).find(" ");
        }
        name = "";
        for (var i = 0; i < segments.size(); i++) {
          var segment = segments[i];
          if (i == segments.size() - 1 || terminalSegments.hasKey(segments[i+1])) {
            if (preTerminalTransformations.hasKey(segment)) {
              segments[i] = preTerminalTransformations[segment];
            }
          }
        }
        fairlyAbbreviate(segments, len);
        name = "";
        for (var i = 0; i < segments.size(); i++) {
          name += segments[i];
        }
        return name;
    }

    static function min(a, b) {
      if (a < b) {
        return a;
      }
      return b;
    }
}
