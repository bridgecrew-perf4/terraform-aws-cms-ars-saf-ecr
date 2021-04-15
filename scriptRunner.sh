#! /usr/bin/env bash

#  not using -e option as the inspec command returns non 0 error code
set -o pipefail

echo "starting Inpsec scan"

# log output of inspec run to stdout
inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --target aws:// --chef-license accept-silent --no-color

# if the s3_bucket_path is not provided, do not push json file to the bucket
# shellcheck disable=SC2154
if [[ -n $s3_bucket_path ]]; then
    echo "s3_bucket_path values found: $s3_bucket_path"
    filename="$(date '+%Y-%m-%d-%H-%M-%S').json"
    inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --reporter json --target aws:// --chef-license accept-silent | aws s3 cp - "$s3_bucket_path/$filename"
    echo "s3 scan results upload complete"
else
    echo "s3_bucket_path variable not found, skipping s3 results upload."
fi

echo "InpSec scan completed successfully"
