package main

import (
	"context"
	"encoding/json"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"

	"log-service/internal/models"
)

var dbClient *dynamodb.Client
var tableName, gsiName, gsiPartitionKey string

func init() {
	cfg, _ := config.LoadDefaultConfig(context.TODO())
	dbClient = dynamodb.NewFromConfig(cfg)
	tableName = os.Getenv("TABLE_NAME")
	gsiName = os.Getenv("GSI_NAME")
	gsiPartitionKey = os.Getenv("GSI_PARTITION_KEY")
}

func handler(ctx context.Context, req events.LambdaFunctionURLRequest) (events.LambdaFunctionURLResponse, error) {
	input := &dynamodb.QueryInput{
		TableName:              aws.String(tableName),
		IndexName:              aws.String(gsiName),
		KeyConditionExpression: aws.String("GSIPartitionKey = :gpk"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":gpk": &types.AttributeValueMemberS{Value:gsiPartitionKey},
		},
		ScanIndexForward: aws.Bool(false), // DESCENDING order (newest first)
		Limit:            aws.Int32(100),
	}

	result, err := dbClient.Query(ctx, input)
	if err != nil {
		return events.LambdaFunctionURLResponse{StatusCode: 500, Body: err.Error()}, nil
	}

	var logs []models.LogEntryResponse
	if err := attributevalue.UnmarshalListOfMaps(result.Items, &logs); err != nil {
    return events.LambdaFunctionURLResponse{
        StatusCode: 500,
        Body:       err.Error(),
    }, nil
}

	body, _ := json.Marshal(logs)
	return events.LambdaFunctionURLResponse{
		StatusCode: 200, 
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(body),
	}, nil
}

func main() {
	lambda.Start(handler)
}