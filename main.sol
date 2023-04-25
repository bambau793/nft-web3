// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomNFT is ERC721, VRFConsumerBase {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public tokenIdCounter;

    mapping(bytes32 => address) public requestIdToSender;
    mapping(bytes32 => string) public requestIdToTokenURI;
    mapping(address => uint256[]) public ownerToTokenIds;

    event CreatedNFT(uint256 indexed tokenId, string indexed tokenURI);

    constructor(address _vrfCoordinator, address _linkToken, bytes32 _keyHash, uint256 _fee)
        ERC721("RandomNFT", "RNFT")
        VRFConsumerBase(_vrfCoordinator, _linkToken)
    {
        keyHash = _keyHash;
        fee = _fee;
        tokenIdCounter = 0;
    }

    function requestRandomToken(string memory _tokenURI) public returns (bytes32) {
        bytes32 requestId = requestRandomness(keyHash, fee);
        requestIdToSender[requestId] = msg.sender;
        requestIdToTokenURI[requestId] = _tokenURI;
        return requestId;
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomNumber) internal override {
        address owner = requestIdToSender[_requestId];
        string memory tokenURI = requestIdToTokenURI[_requestId];
        uint256 newItemId = tokenIdCounter++;

        ownerToTokenIds[owner].push(newItemId);
        _safeMint(owner, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit CreatedNFT(newItemId, tokenURI);
    }

    function getMyTokenIds() external view returns (uint256[] memory) {
        return ownerToTokenIds[msg.sender];
    }
}
