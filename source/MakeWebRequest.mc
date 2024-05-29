import Toybox.Communications;
import Toybox.Lang;

(:background)
class MakeWebRequest {
    (:background)
    private static var _options = {                              // set the options
        :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
        :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        :headers => {"Accept-Encoding" => "gzip"},
    };

    (:background)
    private var _context;
    (:background)
    private var _callback;
    (:background)
    private var _responseMethod;

    function initialize(context, callback) {
        me._context = context;
        me._callback = callback;
        me._responseMethod = method(:onResponse);
    }

    (:background)
    function onResponse(code as Number, response) {
        _callback.invoke(code, response, _context);
    }

    (:background)
    function call(url as String) {
        Communications.makeWebRequest(url, {}, _options, _responseMethod);
    }
}