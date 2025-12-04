import AWS from "aws-sdk";


const TABLE_NAME = process.env.TABLE_NAME || 'QueueCounter';
const COUNTER_ID = process.env.COUNTER_ID || 'global';
const config: any = { region: process.env.AWS_REGION || 'eu-north-1' };
if (process.env.DYNAMODB_ENDPOINT) config.endpoint = process.env.DYNAMODB_ENDPOINT;



export async function ensureTable() {
    const dynamodb = new AWS.DynamoDB(config);
    const tables = await dynamodb.listTables().promise();
    if (tables.TableNames?.includes(TABLE_NAME)) {
        console.log(`[DynamoDB] Table "${TABLE_NAME}" already exists`);
        return;
    }
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
    const docClient = new AWS.DynamoDB.DocumentClient(config);
    await docClient.put({
        TableName: TABLE_NAME,
        Item: { id: COUNTER_ID, currentCount: 0 },
    }).promise();
    console.log(`[DynamoDB] Initialized counter item in "${TABLE_NAME}".`);
}
// export async function incrementCounter(): Promise<number> {
//   const params: UpdateItemCommandInput = {
//     TableName: TABLE_NAME,
//     Key: { id: { S: COUNTER_ID } },
//     UpdateExpression: 'ADD currentCount :inc',
//     ExpressionAttributeValues: { ':inc': { N: '1' } },
//     ReturnValues: 'UPDATED_NEW',
//   };
//   const cmd = new UpdateItemCommand(params);
//   const res = await client.send(cmd);
//   const val = parseInt(res.Attributes?.currentCount.N || '1');
//   return val;
// }

// export async function getCounter(): Promise<number> {
//   const params: GetItemCommandInput = { TableName: TABLE_NAME, Key: { id: { S: COUNTER_ID } } };
//   const cmd = new GetItemCommand(params);
//   const res = await client.send(cmd);
//   const count = res.Item?.currentCount?.N || '0';
//   return parseInt(count);
// }

// export async function decrementCounter(): Promise<number> {
//   // Read-modify-write: get current then set to current-1 if >0
//   const current = await getCounter();
//   if (current <= 0) return 0;
//   const newVal = current - 1;
//   const params: UpdateItemCommandInput = {
//     TableName: TABLE_NAME,
//     Key: { id: { S: COUNTER_ID } },
//     UpdateExpression: 'SET currentCount = :val',
//     ExpressionAttributeValues: { ':val': { N: String(newVal) } },
//     ReturnValues: 'UPDATED_NEW',
//   };
//   const cmd = new UpdateItemCommand(params);
//   await client.send(cmd);
//   return newVal;
// }
