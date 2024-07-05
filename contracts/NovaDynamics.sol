// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "./ERC721A.sol";

contract NovaDynamics is VRFConsumerBaseV2Plus, ERC721A {
    uint256 public constant MAX_SUPPLY = 11;
    string public unrevealedURI =
        "ipfs://bafybeihv2tecvuo7hiig7jiqmj4psgeqqadbymdfsarfb4oqkxhpspfot4";
    string public baseURI =
        "ipfs://bafybeia3gb6svdth4faowgve5e22syrjwh5vm7lknplpwljcyqrefwflki/";
    mapping(uint256 requestId => uint256 tokenId) private _reveals;
    mapping(uint256 tokenId => uint256 metadata) private _revealedTokens;
    uint256 private constant REVEAL_IN_PROGRESS = 99999;
    // variables for Chainlink VRF
    uint256 private s_subscriptionId;
    address public vrfCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    bytes32 public s_keyHash =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 immutable callbackGasLimit = 200000;
    uint16 immutable requestConfirmations = 3;
    uint32 immutable numWords = 1;

    event TokenOnReveal(uint256 indexed requestId, uint256 tokenId);
    event TokenRevealed(uint256 indexed requestId, uint256 result);

    constructor(
        uint256 subscriptionId
    ) VRFConsumerBaseV2Plus(vrfCoordinator) ERC721A("Nova Dynamics", "NOVA") {
        _mint(owner(), MAX_SUPPLY);
        s_subscriptionId = subscriptionId;
    }

    function reveal(uint256 tokenId) public returns (uint256 requestId) {
        require(_revealedTokens[tokenId] == 0, "NOVA: token already revealed");
        require(
            ownerOf(tokenId) == msg.sender,
            "NOV: caller is not the owner of the token"
        );
        require(
            tokenId < MAX_SUPPLY,
            "NOV: token ID is greater or equal than MAX_SUPPLY"
        );

        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        _reveals[requestId] = tokenId;
        _revealedTokens[tokenId] = REVEAL_IN_PROGRESS;

        emit TokenOnReveal(requestId, tokenId);
    }

    // function revealAll(
    //     uint256[] calldata tokenIds
    // ) public returns (uint256[] memory) {
    //     uint256[] memory revealedTokenIds;

    //     for (uint i = 0; i < tokenIds.length; i++) {
    //         uint256 token = tokenIds[i];

    //         if (ownerOf(token) != _msgSender()) continue;
    //         if (token > MAX_SUPPLY) continue;

    //         revealedTokenIds[i] = token;
    //     }

    //     return revealedTokenIds;
    // }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 d20Value = (randomWords[0] % 20) + 1;
        _revealedTokens[_reveals[requestId]] = d20Value;
        emit TokenRevealed(requestId, d20Value);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        if (!_exists(tokenId)) _revert(URIQueryForNonexistentToken.selector);

        if (
            _revealedTokens[tokenId] == 0 ||
            _revealedTokens[tokenId] == REVEAL_IN_PROGRESS
        ) {
            return unrevealedURI;
        } else {
            string memory tokenBaseURI = _baseURI();
            return
                bytes(tokenBaseURI).length != 0
                    ? string(
                        abi.encodePacked(
                            tokenBaseURI,
                            getMetadata(_revealedTokens[tokenId]),
                            ".json"
                        )
                    )
                    : "";
        }
    }

    function setBaseURI(string memory newBaseURI) external onlyOwner {
        baseURI = newBaseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function getMetadata(uint256 tokenId) private view returns (string memory) {
        string[20] memory metadata = [
            "scout",
            "phantom",
            "raider",
            "sentinel",
            "titan",
            "scout",
            "phantom",
            "raider",
            "sentinel",
            "titan",
            "scout",
            "phantom",
            "raider",
            "sentinel",
            "titan",
            "scout",
            "phantom",
            "raider",
            "sentinel",
            "titan"
        ];

        return metadata[_revealedTokens[tokenId]];
    }
}
