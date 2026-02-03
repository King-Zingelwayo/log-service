package models

type LogEntry struct {
	ID              string `json:"id" dynamodbav:"ID"`
	Severity        string `json:"severity" dynamodbav:"Severity"`
	Message         string `json:"message" dynamodbav:"Message"`
	DateTime        string `json:"date_time" dynamodbav:"DateTime"`
	GSIPartitionKey string `json:"gsi_partition_key" dynamodbav:"GSIPartitionKey"`
}

type LogEntryResponse struct {
	ID       string `json:"id"`
	Severity string `json:"severity"`
	Message  string `json:"message"`
	DateTime string `json:"date_time"`
}
