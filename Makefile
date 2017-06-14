.DEFAULT_GOAL=build
.PHONY: build test run

clean:
	go clean .

build: format vet generate
	go build .

test: build
	go test ./test/...

delete:
	go run main.go delete

explore:
	go run main.go --level info explore

provision:
	go run main.go provision --s3Bucket $(S3_BUCKET) --level info

describe: build
	S3_TEST_BUCKET="" SNS_TEST_TOPIC="" DYNAMO_TEST_STREAM="" go run main.go describe --out ./graph.html
