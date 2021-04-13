#! /usr/bin/env bash

set -eo pipefail

# log output of inspec run to stdout
inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --target aws:// --chef-license accept-silent --no-color

# if the s3_bucket_path is not provided, do not push json file to the bucket
# shellcheck disable=SC2154
if [[ -n $s3_bucket_path ]]; then
    inspec exec /home/default/profiles/cms-ars-3.1-moderate-aws-foundations-cis-overlay --reporter json --target aws:// --chef-license accept-silent | aws s3 cp - "$s3_bucket_path"
fi
