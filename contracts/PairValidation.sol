// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

error PairValidation__DuplicateRequest();
error PairValidation__NothingToAccept();
error PairValidation__URI_QueryFor_NonExistentToken();

contract PairValidation is ERC721URIStorage, Ownable {
    uint256 private s_tokenCounter;
    uint256 private s_mappingSize;

    string[5] private imageArr = [
        "ipfs://Qmc8zbipExt4WY53isyxWQeVBYr6iM4Q7vTrWH6sLkhtus",
        "ipfs://Qmf7cT1HG6cmMuyyibTtApwKJwu8xebNJ2trWsgHRrd4gU",
        "ipfs://QmT6ucfKptoW9VxriBHPmBRatoSVPuyYHa57uWNWxzaW3D",
        "ipfs://Qmf59LDgk2duq7UseD7DxK4LG89NmGo2eUJC3z5jB5Fxfn",
        "ipfs://QmVUv6ZH7E317jGSXAXqo7xYRshY2VL939Fhsh2CWhJs6K"
    ];

    string[5] private imageName = [
        "BrokeVim",
        "Origin Master",
        "Pair Programming",
        "Screw it!",
        "Solo"
    ];

    struct RequestDetails {
        address requestorAddress;
        uint256 exist;
        string name1;
        string name2;
        uint256 tokenType;
    }

    event RequestSubmitted(address indexed verifier);
    event NftMinted(address indexed verifier);

    mapping(address => RequestDetails) private s_activeRequests;

    modifier NoDuplicate(address requestor, address acceptor) {
        RequestDetails memory reqDetails = s_activeRequests[acceptor];
        if (reqDetails.requestorAddress == requestor) {
            revert PairValidation__DuplicateRequest();
        }
        _;
    }

    modifier hasRequestToAccept(address acceptor) {
        RequestDetails memory reqDetails = s_activeRequests[acceptor];
        if (reqDetails.exist < 1) {
            revert PairValidation__NothingToAccept();
        }
        _;
    }

    constructor() ERC721("PairTesting", "PTS") {
        s_tokenCounter = 0;
        s_mappingSize = 0;
    }

    function submitRequestForNft(
        address verifier,
        string memory name1,
        string memory name2,
        uint256 imageId
    ) external NoDuplicate(msg.sender, verifier) {
        s_activeRequests[verifier] = RequestDetails(msg.sender, 1, name1, name2, imageId);
        s_mappingSize++;
        emit RequestSubmitted(verifier);
    }

    function acceptNft() external hasRequestToAccept(msg.sender) {
        address requestor = s_activeRequests[msg.sender].requestorAddress;
        string memory requestorURI = createTokenURI(
            s_activeRequests[msg.sender].name1,
            s_activeRequests[msg.sender].name2,
            s_activeRequests[msg.sender].tokenType
        );
        _safeMint(requestor, s_tokenCounter);
        _setTokenURI(s_tokenCounter, requestorURI);
        s_tokenCounter = s_tokenCounter + 1;
        string memory senderURI = createTokenURI(
            s_activeRequests[msg.sender].name1,
            s_activeRequests[msg.sender].name2,
            s_activeRequests[msg.sender].tokenType
        );
        _safeMint(msg.sender, s_tokenCounter);
        _setTokenURI(s_tokenCounter, senderURI);
        s_tokenCounter = s_tokenCounter + 1;
        delete (s_activeRequests[msg.sender]);
        s_mappingSize--;
        emit NftMinted(msg.sender);
    }

    function createTokenURI(
        string memory name1,
        string memory name2,
        uint256 imageId
    ) public view virtual returns (string memory) {
        string memory image = imageArr[imageId];
        string memory nftName = imageName[imageId];
        string memory names = string(
            abi.encodePacked("Pair Programming token for ", name1, " with ", name2)
        );
        return
            string(
                abi.encodePacked(
                    '{"name":"',
                    nftName,
                    '","description":"',
                    names,
                    '","attributes":[{"trait_type":"Sublayer NFTs early user","value":404}],"image":"',
                    image,
                    '"}'
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view virtual returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tokenURI(tokenId);
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getNftRequest(address verifier) public view returns (RequestDetails memory) {
        return s_activeRequests[verifier];
    }

    function getMappingSize() public view returns (uint256) {
        return s_mappingSize;
    }
}
