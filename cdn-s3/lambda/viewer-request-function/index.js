'use strict';

const querystring = require('querystring');

// defines the allowed dimensions, default dimensions and how much variance from allowed
// dimension is allowed.

const variables = {
  allowedSize: ['small', 'large'],
};

exports.handler = (event, context, callback) => {
  const request = event.Records[0].cf.request;

  // parse the querystrings key-value pairs. In our case it would be d=100x100
  const params = querystring.parse(request.querystring);

  // fetch the uri of original image
  let fwdUri = request.uri;

  // if there is no dimension attribute, just pass the request
  if (!params.s) {
    console.log('no param');
    callback(null, request);
    return;
  }
  const size = params.s;
  // read the dimension parameter value = width x height and split it by 'x'

  if (!variables.allowedSize.includes(size)) {
    console.log('invalid size :%s', size);
    callback(null, request);
    return;
  }

  // parse the prefix, image name and extension from the uri.
  // In our case /images/image.jpg
  // /images/1m000000000000000000000000/01g2q8w7kad45a6s57np8nvn2z_01g2q8wa8epjp66sbgger22yc3.jpg

  const match = fwdUri.match(/(.*)\/(.*)\/(.*)\.(.*)/);
  if (!match) {
    console.log('not found');
    callback(null, request);
    return;
  }

  let prefix1 = match[1];
  let userId = match[2];
  let imageName = match[3];
  let extension = match[4];

  let url = [];
  // build the new uri to be forwarded upstream
  url.push(prefix1);
  url.push(size);
  url.push(extension);
  url.push(userId);

  url.push(imageName + '.' + extension);

  fwdUri = url.join('/');
  // /images/small/jpg/1m000000000000000000000000/01g2q8w7kad45a6s57np8nvn2z_01g2q8wa8epjp66sbgger22yc3.jpg

  request.uri = fwdUri;
  callback(null, request);
};
