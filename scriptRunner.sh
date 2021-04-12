#! /usr/bin/env bash

set -eo pipefail

# if the s3_bucket_path is not provided, do not push json file to the bucket
if [[ -n $s3_bucket_path ]]; then 
    inspec exec ./cms-ars-3.1-moderate-aws-foundations-cis-overlay --reporter json | aws s3 cp - $s3_bucket_path
fi

#
inspec exec ./cms-ars-3.1-moderate-aws-foundations-cis-overlay