.DEFAULT_GOAL=build
.PHONY: build test get run

ensure_vendor:
	mkdir -pv vendor

clean:
	rm -rf ./vendor
	go clean .

get: clean ensure_vendor
	git clone --depth=1 https://github.com/aws/aws-sdk-go ./vendor/github.com/aws/aws-sdk-go
	rm -rf ./src/main/vendor/github.com/aws/aws-sdk-go/.git
	git clone --depth=1 https://github.com/go-ini/ini ./vendor/github.com/go-ini/ini
	rm -rf ./vendor/github.com/go-ini/ini/.git
	git clone --depth=1 https://github.com/jmespath/go-jmespath ./vendor/github.com/jmespath/go-jmespath
	rm -rf ./vendor/github.com/jmespath/go-jmespath/.git
	git clone --depth=1 https://github.com/Sirupsen/logrus ./vendor/github.com/Sirupsen/logrus
	rm -rf ./src/main/vendor/github.com/Sirupsen/logrus/.git
	git clone --depth=1 https://github.com/voxelbrain/goptions ./vendor/github.com/voxelbrain/goptions
	rm -rf ./src/main/vendor/github.com/voxelbrain/goptions/.git
	git clone --depth=1 https://github.com/mjibson/esc ./vendor/github.com/mjibson/esc
	rm -rf ./src/main/vendor/github.com/mjibson/esc/.git
	git clone --depth=1 https://github.com/mweagle/Sparta ./vendor/github.com/mweagle/Sparta
	rm -rf ./src/main/vendor/github.com/mweagle/Sparta/.git
	git clone --depth=1 https://github.com/crewjam/go-cloudformation ./vendor/github.com/crewjam/go-cloudformation
	rm -rf ./src/main/vendor/github.com/crewjam/go-cloudformation/.git

test: build
	go test ./test/...

delete:
	go run application.go delete

explore:
	go run application.go --level info explore

provision:
	go run application.go provision --s3Bucket $(S3_BUCKET)

describe: build
	S3_TEST_BUCKET="" SNS_TEST_TOPIC="" DYNAMO_TEST_STREAM="" go run application.go describe --out ./graph.html
