var body_parser = require('body-parser');
var iconv = require('iconv-lite');
var util = require('util');

var module_tag = {
  module: require('../../logger.js').getModulePath(__filename)
};

/**
 * Parse the body of the request for `application/x-www-form-urlencoded`
 * form-data, and handle errors afterwards. Fix body-parser compatability
 * (https://github.com/expressjs/body-parser/issues/100) so that requests with
 * headers specifying a Content-Type other than UTF-8 are parsed correctly.
 * Note that `req.headers[]` has all-lowercase key names (e.g. 'content-type').
 */
module.exports = function(proxy) {
  return function(req, res, next) {
    // HACK: Remove incompatible headers from the request, and stash them for later.
    proxy.logger.debug(module_tag, "%s %s: headers\n", req.method, req.url, req.headers);
    if (req.headers['content-type'] && req.headers['content-type'].indexOf('application/x-www-form-urlencoded') === 0) {
      req.cached_header = req.headers['content-type'];
      req.headers['content-type'] = 'application/x-www-form-urlencoded';
    }

    var parser = body_parser.urlencoded({ extended: true, limit: '1mb' });
    parser(req, res, function(err) {
      // Handle errors
      if (err) return next(err);

      if (req.cached_header) {
        req.headers['content-type'] == req.cached_header;
      }

      // Continue chain
      next();
    });
  };
};
