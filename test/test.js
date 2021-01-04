const chai = require("chai");
const expect = chai.expect;
const request = require("./helper.js");

chai.use(require("chai-http"));

describe("origami-imageset-data", () => {
  it("serve lionel barber", () => {
    return request
      .get("https://origami-images.ft.com/fthead/v1/lionel-barber")
      .then(res => {
        expect(res).to.have.status(200);
        expect(res).to.have.header("Content-Type", "image/png");
      });
  });

  it("purging requires an API key", () => {
    return request
      .purge("https://origami-images.ft.com/fthead/v1/lionel-barber")
      .then(
        res => {
          throw new Error("Expected request to be rejected but was resolved.");
        },
        err => {
          expect(err).to.have.status(401);
        }
      );
  });
});
