exports.handler = async (event) => {
  const { word, pos } = event.pathParameters;

  const item = await ddb
    .query({
      TableName: process.env.table_name,
      IndexName: "word-pos-index",
      KeyConditionExpression: "word = :word and pos = :pos",
      ExpressionAttributeValues: {
        ":word": word.toUpperCase(),
        ":pos": pos,
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
