// Retrieve fixture ID from arguments				
//let date = args[0];								
// Check if fixture ID is missing				
//if (!date) {				
//	// Log a message saying missing Fixture ID and use default value	
//	console.log("Missing the date. We'll use default value");
//	date = '2024-05-15' // Default, as a string!			
//}						
// Make the HTTP Request with Functions.makeHttpRequest				
	const apiResponse = await Functions.makeHttpRequest({			
	url: 'https://api.sportmonks.com/v3/football/fixtures/date/2024-05-15?api_token=ZvZv41TCMKM8sl7HTmJp253s6X7ZGSoXVgc4I4KeGrMRo3WmftQOWSVLIFBU&includes=scores'			
});				
// Check if there were any errors in our API Request				
	if (apiResponse.error) {			
	// Log an error message and throw an Error to halt execution			
	console.log("There was an error, mate.");			
	throw new Error("Request failed, mate.");			
}							
// Extract the data I want from the API Response				
	let dataPoint1 = apiResponse.data[0].length;			
// We'll log out this data point so we can see it in our console log		
	console.log(dataPoint1);			
// Now well return this data point as a rounded uint256, to our smart contract	
	return Functions.encodeUint256(Math.round(dataPoint1));	