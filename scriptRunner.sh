#! /usr/bin/env bash

set -eo pipefail

echo "starting Inpsec scan, start"

# log output of inspec run to stdout
inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --target aws:// --chef-license accept-silent --no-color

echo "starting Inpsec scan, stop"


# if the s3_bucket_path is not provided, do not push json file to the bucket
# shellcheck disable=SC2154
if [[ -n $s3_bucket_path ]]; then
    echo "s3_bucket_path values found: $s3_bucket_path"
    inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --reporter json --target aws:// --chef-license accept-silent | aws s3 cp - "$s3_bucket_path"
else
    echo "s3_bucket_path variable not found, skipping s3 results upload."
fi
