"use strict";
exports.handler = (event, context, callback) => {  
    
  const response = event.Records[0].cf.response;
  const headers = response.headers;
  

  headers["cache-control"] = [
    {
      key: "Cache-Control",
      value: "max-age=3600"
    },  
  ];
  headers["x-robots-tag"] = [
    {
      key: "X-Robots-Tag",
      value: "noindex"
    },  
  ];
  

  callback(null, response);
};
