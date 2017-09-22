# origami-imageset-data [![CircleCI](https://circleci.com/gh/Financial-Times/origami-imageset-data.svg?style=svg&circle-token=24cc8815476c14448f56545b216b6482a5b9762e)](https://circleci.com/gh/Financial-Times/workflows/origami-imageset-data/tree/master)

Serve Origami Imageset images through Fastly.

## Why?

To have the images cached and served from the edge with multi-region failover.

## Information

The Fastly service ID is [`3cUsylommuzAVcvd80Sk5A`](https://manage.fastly.com/dashboard/services/3cUsylommuzAVcvd80Sk5A/datacenters/all).

CircleCI environment variables are:

* `FASTLY_API_KEY` to deploy to Fastly
* `FASTLY_S3_ACCESS_KEY` for logging to S3
* `FASTLY_S3_SECRET_KEY` for logging to S3
* `CIRCLE_TOKEN` to limit deploys to one at a time
