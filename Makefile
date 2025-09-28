.PHONY: push run run-drafts kill

push:
	hugo
	aws s3 sync ./public/ s3://www.bencode.net --acl public-read
	aws cloudfront create-invalidation --distribution-id=E1AOP3LBMEJ3M9 --paths "/*"

run:
	hugo server

run-drafts:
	hugo server -D

kill:
	killall hugo
