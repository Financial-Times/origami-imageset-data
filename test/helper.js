const chai = require("chai");
const URL = require("url").URL;

chai.use(require("chai-http"));

// Handle the weird promise rejection required to test redirects.
module.exports = {
  get: url => {
    const { host, pathname, search } = new URL(url);

    return chai
      .request("https://f3.shared.global.fastly.net")
      .get(`${pathname}${search}` || "")
      .set("Host", host);
  },
  purge: url => {
    const { host, pathname, search } = new URL(url);

    return chai
      .request("https://f3.shared.global.fastly.net")
      .purge(`${pathname}${search}` || "")
      .set("Host", host);
  }
};
