package main

//go:generate rm -rf ./static/public
//go:generate hugo --source ./static

import (
	"context"
	"fmt"
	"net/http"

	sparta "github.com/mweagle/Sparta"
	spartaCF "github.com/mweagle/Sparta/aws/cloudformation"
)

////////////////////////////////////////////////////////////////////////////////
// Hello world event handler
//
func helloWorld(ctx context.Context, event map[string]interface{}) (interface{}, error) {
	response := map[string]interface{}{
		"Message": "Hello World",
		"Event":   event,
	}
	return response, nil
}

func spartaLambdaFunctions(api *sparta.API) []*sparta.LambdaAWSInfo {
	var lambdaFunctions []*sparta.LambdaAWSInfo
	lambdaFn := sparta.HandleAWSLambda("Hello World",
		helloWorld,
		sparta.IAMRoleDefinition{})

	if nil != api {
		apiGatewayResource, _ := api.NewResource("/hello", lambdaFn)
		method, methodErr := apiGatewayResource.NewMethod("GET", http.StatusOK, http.StatusOK)
		if methodErr != nil {
			panic("Failed to create /hello resource")
		}
		method.SupportedRequestContentTypes = []string{"application/json"}
	}
	return append(lambdaFunctions, lambdaFn)
}

////////////////////////////////////////////////////////////////////////////////
// Main
func main() {
	// Register the function with the API Gateway
	apiStage := sparta.NewStage("v1")
	apiGateway := sparta.NewAPIGateway("SpartaHugo", apiStage)
	// Enable CORS s.t. the S3 site can access the resources
	apiGateway.CORSEnabled = true

	// Provision a new S3 bucket with the resources in the supplied subdirectory
	s3Site, _ := sparta.NewS3Site("./static/public")

	// Deploy it
	stackName := spartaCF.UserScopedStackName("SpartaHugo")
	sparta.Main(stackName,
		fmt.Sprintf("Sparta app that provisions a CORS-enabled API Gateway together with an S3 site built by Hugo (http://gohugo.io)"),
		spartaLambdaFunctions(apiGateway),
		apiGateway,
		s3Site)
}
