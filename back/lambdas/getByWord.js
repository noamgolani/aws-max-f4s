const AWS = require("aws-sdk");
const ddb = new AWS.DynamoDB.DocumentClient({ region: "eu-west-1" });

exports.handler = async (event) => {
  const { word } = event.pathParameters;

  const item = await ddb
    .query({
      TableName: process.env.table_name,
      IndexName: "word-pos-index",
      KeyConditionExpression: "word = :word",
      ExpressionAttributeValues: {
        ":word": word.toUpperCase(),
      },
    })
    .promise();

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "OPTIONS,POST,GET",
    },
    body: JSON.stringify(item),
  };
  return response;
};
