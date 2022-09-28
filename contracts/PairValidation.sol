// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error PairValidation__DuplicateRequest();
error PairValidation__NothingToAccept();
error PairValidation__URI_QueryFor_NonExistentToken();

contract PairValidation is ERC721 {
    uint256 private s_tokenCounter;
    uint256 private s_mappingSize;
    string public constant TOKEN_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";

    struct RequestDetails {
        address requestorAddress;
        uint256 id;
        string name1;
        string name2;
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
        if (reqDetails.id <= 0) {
            revert PairValidation__NothingToAccept();
        }
        _;
    }

    constructor() ERC721("PairProgramming", "PPM") {
        s_tokenCounter = 0;
        s_mappingSize = 0;
    }

    function submitRequestForNft(
        address verifier,
        string memory name1,
        string memory name2
    ) external NoDuplicate(msg.sender, verifier) {
        s_activeRequests[verifier] = RequestDetails(msg.sender, 1, name1, name2);
        s_mappingSize++;
        emit RequestSubmitted(verifier);
    }

    function acceptNft() external hasRequestToAccept(msg.sender) {
        address requestor = s_activeRequests[msg.sender].requestorAddress;
        _safeMint(requestor, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter = s_tokenCounter + 1;
        delete (s_activeRequests[msg.sender]);
        s_mappingSize--;
        emit NftMinted(msg.sender);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        if (!_exists(tokenId)) {
            revert PairValidation__URI_QueryFor_NonExistentToken();
        }
        return TOKEN_URI;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getNftRequest(address verifier) public view returns (RequestDetails memory) {
        return s_activeRequests[verifier];
    }

    function getTokenURI() public pure returns (string memory) {
        return TOKEN_URI;
    }

    function getMappingSize() public view returns (uint256) {
        return s_mappingSize;
    }
}

/*
function tokenURI(uint256 tokenId, string memory name1, string memory name 2) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert PairValidation__URI_QueryFor_NonExistentToken();
        }
        string memory names = string.concat("Pair Programming token for ",name1," with ", name2);
        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(), // You can add whatever name here
                                '", "description":"An NFT that changes based on the Chainlink Feed", ',
                                '"attributes": [{"trait_type": "coolness", "value": 100}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }
*/
