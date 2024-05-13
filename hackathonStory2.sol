// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts@4.6.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.6.0/access/Ownable.sol";
import "@openzeppelin/contracts@4.6.0/utils/Counters.sol";

contract hackathonStory2 is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // Metadata information for each stage of the NFT on IPFS.
    string[] IpfsUri = [
        "https://black-reasonable-grouse-549.mypinata.cloud/ipfs/QmQm2s6jWP3W6imUrKGwCg3khcoZRsKb2Uv4wCpx7gnL5o",
        "https://black-reasonable-grouse-549.mypinata.cloud/ipfs/QmcEy3HbvQyv97f4ai4iqwmm27G64q3QffuRi28v4g6TnJ"
    ];

    uint256 lastTimeStamp;
    uint256 interval;

    constructor(
        uint256 _interval
    ) ERC721("NoobLink Ninjas Testing Collection", "TCKT") {
        //constructor() ERC721("NoobLink Ninjas Testing Collection", "TCKT") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            gamePlayed(0);
        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, IpfsUri[0]);
    }

    function gamePlayed(uint256 _tokenId) public {
        if (gameStage(_tokenId) >= 1) {
            return;
        }
        // Get the current stage of the flower and add 1
        uint256 newVal = gameStage(_tokenId) + 1;
        // store the new URI
        string memory newUri = IpfsUri[newVal];
        // Update the URI
        _setTokenURI(_tokenId, newUri);
    }

    // determine the stage of the flower growth
    function gameStage(uint256 _tokenId) public view returns (uint256) {
        string memory _uri = tokenURI(_tokenId);
        // Pre-Game
        if (compareStrings(_uri, IpfsUri[0])) {
            return 0;
        }
        // Must be Full Time Final Result
        return 1;
    }

    /*
     ********************
     * HELPER FUNCTIONS *
     ********************
     */
    // helper function to compare strings
    function compareStrings(
        string memory a,
        string memory b
    ) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
