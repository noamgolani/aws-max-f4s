import {
	DynamoDBClient,
	ListTablesCommand,
	BatchWriteItemCommand,
} from "@aws-sdk/client-dynamodb";
import fs from "fs/promises";

const dicJsonToPut = ({ pos, word, definitions, synonyms, index }) => {
	return {
		PutRequest: {
			Item: {
				...{
					pos: {
						S: pos,
					},
					word: {
						S: word,
					},
					id: {
						N: index.toString(),
					},
					definitions: {
						SS: [...new Set(definitions)],
					},
				},
				...(synonyms
					? {
							synonyms: {
								S: synonyms,
							},
					  }
					: {}),
			},
		},
	};
};

(async () => {
	const dictionary = await fs.readFile("./dictionary.json");
	const dicJson = JSON.parse(dictionary.toString());
	const chunks = [];
	for (let i = 0; i < dicJson.length; i += 1) {
		chunks[Math.floor(i / 25)] = chunks[Math.floor(i / 25)] || [];
		chunks[Math.floor(i / 25)].push(
			dicJsonToPut({ ...dicJson[i], index: i })
		);
	}

	const client = new DynamoDBClient({ region: "eu-west-1" });

	const offset = 3001;
	const timeout = 0;
	for (let reqIndex = offset; reqIndex < chunks.length; reqIndex += 1) {
		const params = {
			RequestItems: {
				dictionary: chunks[reqIndex],
			},
			ReturnConsumedCapacity: "TOTAL",
		};

		const res = await client.send(new BatchWriteItemCommand(params));
		console.log(
			`Number ${reqIndex} / ${chunks.length}: ${res.ConsumedCapacity[0].CapacityUnits}`
		);

		await new Promise((res, rej) => {
			setTimeout(res, timeout);
		});
	}
})();
