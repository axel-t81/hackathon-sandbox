// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy on Polygon Amoy

// Import from the Functions package
import {FunctionsClient} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import {FunctionsRequest} from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";

// The Solidity contract that I am creating
contract ScoreFunctions is FunctionsClient {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string home,
        string away,
        bytes response,
        bytes err
    );

    // Hardcoded for Amoy
    // Supported networks https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0xC22a79eBA640940ABB6dF0f7982cc119578E11De;
    bytes32 donID =
        0x66756e2d706f6c79676f6e2d616d6f792d310000000000000000000000000000;

    //Callback gas limit
    uint32 gasLimit = 300000;

    // Your subscription ID.
    uint64 public s_subscriptionId;

    // JavaScript source code
    // STUCK HERE: NEED TO COME BACK HERE
    string source =
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: `https://swapi.dev/api/people/${characterId}/`"
        "});"
        "if (apiResponse.error) {"
        "throw Error('Request failed');"
        "}"
        "const { data } = apiResponse;"
        "return Functions.encodeString(data.name);";
    //string public source =
    //    "const fixtureid = args[0];"
    //    "const apiResponse = await Functions.makeHttpRequest({"
    //    "url: `https://api.sportmonks.com/v3/football/fixtures/fixtureid?api_token=MY_API_TOKEN_ENTERED_HERE&includes=scores',"
    //    "responseType: 'text'"
    //    "});"
    //    "if (apiResponse.error) {"
    //    "throw Error('Request failed');"
    //    "}"
    //    "const { data } = apiResponse;"
    //    "return Functions.encodeString(data);";
    // STUCK HERE: NEED TO COME BACK HERE
    string public character;

    string public lastFixtureID;
    string public lastHome;
    string public lastAway;

    // The contstructor that initialises data when contract is created
    constructor(uint64 subscriptionId) FunctionsClient(router) {
        s_subscriptionId = subscriptionId;
    }

    //* Chainlink Functions works by (1) sending a request to the DON
    //* (2) Letting the DON call the API off-chain
    //* (3) And then DON will fulfill the request and push the data on-chain

    // This is the function to send the request to the DON; the first step
    function getScore(
        string memory _fixtureID
    ) external returns (bytes32 requestId) {
        string[] memory args = new string[](1);
        args[0] = _fixtureID;

        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            s_subscriptionId,
            gasLimit,
            donID
        );
        lastFixtureID = _fixtureID;

        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    // This is the function that fulfills the request; the third and final step
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        s_lastError = err;

        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        lastHome = string(response);
        lastAway = string(response);

        // Emit an event to log the response
        emit Response(
            requestId,
            lastHome,
            lastAway,
            s_lastResponse,
            s_lastError
        );
    }
}
