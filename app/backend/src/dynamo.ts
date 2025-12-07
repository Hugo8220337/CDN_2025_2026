import AWS from "aws-sdk";

const TABLE_NAME = process.env.TABLE_NAME || 'QueueCounter';
const COUNTER_ID = process.env.COUNTER_ID || 'global';
const config: any = {
    region: process.env.AWS_REGION || 'eu-north-1',
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'fake',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'fake',
};
if (process.env.DYNAMODB_ENDPOINT) {
    config.endpoint = process.env.DYNAMODB_ENDPOINT;
    config.sslEnabled = false;
    config.credentials = new AWS.Credentials('fake', 'fake'); // Explicitly set fake credentials
}

export const dynamodb = new AWS.DynamoDB(config);
export const docClient = new AWS.DynamoDB.DocumentClient(config);

/**
 * Ensures that the DynamoDB table exists; creates it if it does not.
 * @returns 
 */
export async function ensureTable() {
    // Check if table exists
    const tables = await dynamodb.listTables().promise();
    if (tables.TableNames?.includes(TABLE_NAME)) {
        console.log(`[DynamoDB] Table "${TABLE_NAME}" already exists`);
        return;
    }

    // Create table if it does not exist
    console.log(`[DynamoDB] Creating table "${TABLE_NAME}"...`);
    const params: AWS.DynamoDB.CreateTableInput = {
        TableName: TABLE_NAME,
        KeySchema: [{ AttributeName: 'id', KeyType: 'HASH' }],
        AttributeDefinitions: [{ AttributeName: 'id', AttributeType: 'S' }],
        ProvisionedThroughput: { ReadCapacityUnits: 5, WriteCapacityUnits: 5 },
    };
    await dynamodb.createTable(params).promise();
    console.log(`[DynamoDB] Table "${TABLE_NAME}" created.`);

    // Initialize counter item
    await docClient.put({
        TableName: TABLE_NAME,
        Item: { id: COUNTER_ID, currentCount: 0 },
    }).promise();
    console.log(`[DynamoDB] Initialized counter item in "${TABLE_NAME}".`);
}