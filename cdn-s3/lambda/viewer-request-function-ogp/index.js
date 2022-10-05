'use strict';
const axios = require('axios');
// const querystring = require('querystring');
// const API_URL = 'https://api.dev.diglee.social/v1/contents';
// const PUBLIC_URL = 'https://dev.diglee.social';

const API_URL = 'https://api.diglee.social/v1/contents';
const PUBLIC_URL = 'https://diglee.social';


// axios.get(PUBLIC_URL).then((res) => {
//   // console.log(res.data);
//   let html = res.data
//   const title = "new title"
//   const url = "new title"
//   html = html.replace("<title>DigLee - マップ型SNSサービス</title>",`<title>${title}</title>`);
//   html = html.replace("<meta property=\"og:title\" content=\"DigLee - マップ型SNSサービス\"/>",`<meta property=\"og:title\" content="${title}"/>`);
//   html = html.replace("https://diglee.social/apple-touch-icon.png",url);
//   console.log(html,"html");

// });

exports.handler = async (event, context, callback) => {
  const request = event.Records[0].cf.request;
  console.log(request,"request")
  // /contents/01gdenvrn4dde9bffr9n5a66d2
  const paths = request.uri.split('/').slice(-2);
  console.log(paths,"paths")

  const resHTML = await axios.get(PUBLIC_URL);
  const indexHTML = resHTML.data


  // Create OGP response
  if (validatePath(paths)) {
    const contentId = paths[1];
    //OGP用データ取得
    const res = await axios.get(`${API_URL}/${contentId}`);

    const replacedHTML = replaceHTML(
      indexHTML,
      res.data.body,
      `${res.data.content_image_url}?s=small`,
      PUBLIC_URL + request.uri
    )

    const headers = {"content-type" : [
      {
        key: "Content-Type",
        value: "text/html"
      },  
    ]}

    const ogpResponse = {
      status: 200,
      headers: headers,
      body: replacedHTML,
    };

    console.log(ogpResponse, 'response');
    callback(null, ogpResponse);
    return;
  } else {
    const errorResponse = {
      status: 404
    };
    callback(null, errorResponse);
    return
  }
};

const validatePath = (paths) => {
  if(paths.length < 2 ){
    return false
  }
  return paths[0] === "contents"
}

const replaceHTML = (html,title,ogImageURL, url) => {
  if(title) {
    // .replace("<title>DigLee - マップ型SNSサービス</title>",`<title>${title}</title>`)
    return html
    .replace("<meta property=\"og:title\" content=\"DigLee - マップ型SNSサービス\"/>",`<meta property=\"og:title\" content=\"${title}\"/>`)
    .replace("https://diglee.social/apple-touch-icon.png",ogImageURL);
  }
  return html
  .replace("https://diglee.social/apple-touch-icon.png",ogImageURL);

};
