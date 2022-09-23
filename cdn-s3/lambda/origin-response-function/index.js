'use strict';

const AWS = require('aws-sdk');
const S3 = new AWS.S3({
  signatureVersion: 'v4',
});
const Sharp = require('sharp');

// set the S3 endpoints
const ENV = "dev"
// const ENV = 'prod';
const APP = 'diglee';
const BUCKET = `${APP}-${ENV}-public-files-origin`;

const variables = {
  allowedSize: ['small', 'large'],
};

// read the required path. Ex: uri /images/100x100/webp/image.jpg
// images/1m000000000000000000000000/small/jpg/01frd3ztvq26cycdjpynw5k1dw_01frd42ybpcrjzvxkb83g9422e.png
exports.handler = (event, context, callback) => {
  let response = event.Records[0].cf.response;
  let request = event.Records[0].cf.request;

  // TODO通常
  if (response.status == 200) {
    callback(null, response);
    return;
  }

  // console.log('Response status code :%s', response.status);

  //check if image is not present
  if (response.status == 404) {

    // read the required path. Ex: uri /images/100x100/webp/image.jpg
    let path = request.uri;

    // read the S3 key from the path variable.
    // Ex: path variable /images/100x100/webp/image.jpg
    // images/1m000000000000000000000000/small/jpg/01frd3ztvq26cycdjpynw5k1dw_01frd42ybpcrjzvxkb83g9422e.png
    let key = path.substring(1);

    // parse the prefix, width, height and image name
    // Ex: key=images/200x200/webp/image.jpg
    let prefix1, prefix2, originalKey, match, size, requiredFormat, imageName;

    // console.log('uri: %s', path);
    match = key.match(/(.*)\/(.*)\/(.*)\/(.*)\/(.*)/);
    if (!match) {
      console.log('not found');
      callback(null, response);
      return;
    }

    match = key.match(/(.*)\/(.*)\/(.*)\/(.*)\/(.*)/);
    prefix1 = match[1];
    prefix2 = match[2];
    size = match[3];

    // correction for jpg required for 'Sharp'
    requiredFormat = match[4];
    imageName = match[5];
    originalKey = `${prefix1}/${prefix2}/${imageName}`;

    if (!variables.allowedSize.includes(size)) {
      callback(null, response);
      console.log('invalid size :%s', size);
      return;
    }

    const basePixcel = size == 'small' ? 400 : 400;

    // get the source image file
    S3.getObject({ Bucket: BUCKET, Key: originalKey })
      .promise()
      // perform the resize operation
      .then((data) =>
        Sharp(data.Body).resize(basePixcel).toFormat(requiredFormat).toBuffer()
      )
      .then((buffer) => {
        // save the resized object to S3 bucket with appropriate object key.
        S3.putObject({
          Body: buffer,
          Bucket: BUCKET,
          ContentType: 'image/' + requiredFormat,
          CacheControl: 'max-age=31536000', //TODO
          Key: key,
          StorageClass: 'STANDARD',
        })
          .promise()
          // even if there is exception in saving the object we send back the generated
          // image back to viewer below
          .catch(() => {
            console.log('Exception while writing resized image to bucket');
          });

        // generate a binary response with resized image
        response.status = 200;
        response.body = buffer.toString('base64');
        response.bodyEncoding = 'base64';
        response.headers['content-type'] = [
          { key: 'Content-Type', value: 'image/' + requiredFormat },
        ];
        callback(null, response);
      })
      .catch((err) => {
        console.log('Exception while reading source image :%j', err);
      });
      return
  } // end of if block checking response statusCode

  console.log('other status, request', request);
};
