package main

import (
	"context"
	"encoding/json"
	"os"
	"time"
	"strings"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/google/uuid"

	"log-service/internal/models"
)

var dbClient *dynamodb.Client
var tableName, gsiPartitionKey string

func init() {
	cfg, _ := config.LoadDefaultConfig(context.TODO())
	dbClient = dynamodb.NewFromConfig(cfg)
	tableName = os.Getenv("TABLE_NAME")
	gsiPartitionKey = os.Getenv("GSI_PARTITION_KEY")
}

func handler(ctx context.Context, req events.LambdaFunctionURLRequest) (events.LambdaFunctionURLResponse, error) {
	var entry models.LogEntry

    if req.Body == "" {
        return events.LambdaFunctionURLResponse{
            StatusCode: 400, 
            Body: "Request body is required",
        }, nil
    }

    if err := json.Unmarshal([]byte(req.Body), &entry); err != nil {
        return events.LambdaFunctionURLResponse{
            StatusCode: 400, 
            Body: "Invalid JSON format",
        }, nil
    }

    if entry.Severity == "" || entry.Message == "" {
        return events.LambdaFunctionURLResponse{
            StatusCode: 400, 
            Body: "Both 'severity' and 'message' are required in the request body",
        }, nil
    }

    inputSeverity := strings.ToLower(entry.Severity)
    validSeverities := map[string]bool{"info": true, "warning": true, "error": true}
    
    if !validSeverities[inputSeverity] {
        return events.LambdaFunctionURLResponse{
            StatusCode: 400, 
            Body: "Severity must be info, warning, or error",
        }, nil
    }

    entry.Severity = inputSeverity
    entry.ID = uuid.New().String()
    entry.GSIPartitionKey = gsiPartitionKey
    entry.DateTime = time.Now().Format(time.RFC3339)

	item, _ := attributevalue.MarshalMap(entry)
	_, err := dbClient.PutItem(ctx, &dynamodb.PutItemInput{
		TableName: &tableName,
		Item:      item,
	})

	if err != nil {
		return events.LambdaFunctionURLResponse{StatusCode: 500, Body: err.Error()}, nil
	}

	return events.LambdaFunctionURLResponse{StatusCode: 201, Body: "Log ingested"}, nil
}

func main() {
	lambda.Start(handler)
}