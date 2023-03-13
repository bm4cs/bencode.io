# build the static content to the `public` folder
hugo

# Requires awscli
# sudo apt install awscli
# awscli configure
# This will need a new access key through the AWS IAM portal
aws s3 sync ./public/ s3://www.bencode.net --acl public-read

# Invalid cloudfront CDN cache
# To get the distrbution id:
#     aws cloudfront list-distributions | grep \"Id\" --color
aws cloudfront create-invalidation --distribution-id=E1AOP3LBMEJ3M9 --paths "/*"

