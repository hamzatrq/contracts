// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC721.sol";
import "./EnumerableSet.sol";
import "./Math.sol";
import "./WebaverseERC20.sol";

/**
 * @dev Extension of {ERC20} that adds a cap to the supply of tokens.
 */
contract WebaverseERC721 is ERC721 {
    using EnumerableSet for EnumerableSet.UintSet;

    WebaverseERC20 erc20Contract; // ERC20 contract for fungible tokens
    uint256 mintFee; // ERC20 fee to mint ERC721
    address treasuryAddress; // address to pay minting fees
    bool isPublicallyMintable; // whether anyone can mint tokens in this copy of the contract
    mapping (address => bool) allowedMinters; // whether anyone can mint tokens (should be sidechain only)
    uint256 nextTokenId = 0; // the next token id to use (increases linearly)
    mapping (uint256 => uint256) private tokenIdToHash; // map of token id to hash it represents
    mapping (uint256 => uint256) private hashToStartTokenId; // map of hashes to start of token ids for it
    mapping (uint256 => uint256) private hashToTotalSupply; // map of hash to total number of tokens for it
    mapping (uint256 => Metadata[]) private hashToMetadata; // map of hash to metadata key-value store
    mapping (uint256 => address[]) private hashToCollaborators; // map of hash to addresses that can change metadata
    mapping (uint256 => uint256) private tokenIdToBalance; // map of tokens to packed balance

    struct Metadata {
        string key;
        string value;
    }
    
    constructor (string memory name, string memory symbol, WebaverseERC20 _erc20Contract, uint256 _mintFee, address _treasuryAddress, bool _isPublicallyMintable) public ERC721(name, symbol) {
        _setBaseURI("https://tokens.webaverse.com/");
        erc20Contract = _erc20Contract;
        mintFee = _mintFee;
        treasuryAddress = _treasuryAddress;
        isPublicallyMintable = _isPublicallyMintable;
        allowedMinters[msg.sender] = true;
    }

    function setMintFee(uint256 _mintFee) public {
        require(msg.sender == treasuryAddress, "must be set from treasury address");
        mintFee = _mintFee;
    }
    function setTreasuryAddress(address _treasuryAddress) public {
        require(msg.sender == treasuryAddress, "must be set from treasury address");
        treasuryAddress = _treasuryAddress;
    }

    function getPackedBalance(uint256 tokenId) public view returns (uint256) {
        return tokenIdToBalance[tokenId];
    }
    function pack(address from, uint256 tokenId, uint256 amount) public {
        require(_exists(tokenId), "token id does not exist");

        tokenIdToBalance[tokenId] += amount;

        address contractAddress = address(this);
        erc20Contract.transferFrom(from, contractAddress, amount);
    }
    function unpack(address to, uint256 tokenId, uint256 amount) public {
        require(ownerOf(tokenId) == msg.sender, "not your token");
        require(tokenIdToBalance[tokenId] >= amount, "insufficient balance");

        tokenIdToBalance[tokenId] -= amount;

        erc20Contract.transfer(to, amount);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    // 0x08E242bB06D85073e69222aF8273af419d19E4f6, 0x1, "lol", 1
    function mint(address to, uint256 hash, string memory filename, uint256 count) public {
        require(isPublicallyMintable);
        require(hash != 0, "hash cannot be zero");
        require(count > 0, "count must be greater than zero");
        require(hashToTotalSupply[hash] == 0, "hash already exists");

        hashToStartTokenId[hash] = nextTokenId + 1;

        uint256 i = 0;
        while (i < count) {
            uint256 tokenId = ++nextTokenId;

            _mint(to, tokenId);

            tokenIdToHash[tokenId] = hash;
            i++;
        }
        hashToTotalSupply[hash] = count;
        hashToMetadata[hash].push(Metadata("filename", filename));
        hashToCollaborators[hash].push(to);

        if (mintFee != 0) {
            erc20Contract.transferFrom(msg.sender, treasuryAddress, mintFee);
        }
    }
    function streq(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    function mintTokenId(address to, uint256 tokenId, uint256 hash, string memory filename) public {
        require(isAllowedMinter(msg.sender), "minter not allowed");
        require(hash != 0, "hash cannot be zero");

        _mint(to, tokenId);
    
        /* string memory _tokenURI = uint2str(hash);
        _setTokenURI(tokenId, _tokenURI); */
    
        tokenIdToHash[tokenId] = hash;

        if (hashToStartTokenId[hash] == 0) {
          hashToStartTokenId[hash] = tokenId;
        }
        hashToTotalSupply[hash] = hashToTotalSupply[hash] + 1;
        bool filenameFound = false;
        for (uint256 i = 0; i < hashToMetadata[hash].length; i++) {
            if (streq(hashToMetadata[hash][i].key, "filename")) {
                hashToMetadata[hash][i].value = filename;
                filenameFound = true;
                break;
            }
        }
        if (!filenameFound) {
            hashToMetadata[hash].push(Metadata("filename", filename));
        }
        
        if (!isCollaborator(hash, to)) {
            hashToCollaborators[hash].push(to);
        }
    }

    function setBaseURI(string memory baseURI_) public {
        require(allowedMinters[msg.sender], "only minters can set the base uri");
        setBaseURI(baseURI_);
    }
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string(abi.encodePacked(baseURI(), uint2str(tokenId)));
    }
    
    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }
    
    function isAllowedMinter(address a) public view returns (bool) {
        return allowedMinters[a];
    }
    function addAllowedMinter(address a) public {
        require(isAllowedMinter(msg.sender));
        allowedMinters[a] = true;
    }
    function removeAllowedMinter(address a) public {
        require(isAllowedMinter(msg.sender));
        allowedMinters[a] = false;
    }

    function isCollaborator(uint256 hash, address a) public view returns (bool) {
        for (uint256 i = 0; i < hashToCollaborators[hash].length; i++) {
            if (hashToCollaborators[hash][i] == a) {
                return true;
            }
        }
        return false;
    }
    function addCollaborator(uint256 hash, address a) public {
        require(isCollaborator(hash, msg.sender), "you are not a collaborator");
        require(!isCollaborator(hash, a), "they are already a collaborator");
        hashToCollaborators[hash].push(a);
    }
    function removeCollaborator(uint256 hash, address a) public {
        require(isCollaborator(hash, msg.sender), "you are not a collaborator");
        require(isCollaborator(hash, msg.sender), "they are not a collaborator");
        
        uint256 newSize = 0;
        for (uint256 i = 0; i < hashToCollaborators[hash].length; i++) {
            if (hashToCollaborators[hash][i] != a) {
                newSize++;
            }
        }

        address[] memory newCollaborators = new address[](newSize);
        uint256 index = 0;
        for (uint256 i = 0; i < hashToCollaborators[hash].length; i++) {
            address oldCollaborator = hashToCollaborators[hash][i];
            if (oldCollaborator != a) {
                newCollaborators[index++] = oldCollaborator;
            }
        }
        hashToCollaborators[hash] = newCollaborators;
    }
    function seal(uint256 hash) public {
        require(isCollaborator(hash, msg.sender), "not a collaborator");
        delete hashToCollaborators[hash];
    }

    function getHash(uint256 tokenId) public view returns (uint256) {
        return tokenIdToHash[tokenId];
    }
    
    // 0x08E242bB06D85073e69222aF8273af419d19E4f6, 0x1
    function balanceOfHash(address owner, uint256 hash) public view returns (uint256) {
        uint256 count = 0;
        uint256 balance = balanceOf(owner);
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = tokenOfOwnerByIndex(owner, i);
            uint256 h = tokenIdToHash[tokenId];
            if (h == hash) {
                count++;
            }
        }
        return count;
    }
    function totalSupplyOfHash(uint256 hash) public view returns (uint256) {
        return hashToTotalSupply[hash];
    }
    
    function getTokenIdsOf(address owner) public view returns (uint256[] memory) {
        uint256 count = balanceOf(owner);
        uint256[] memory ids = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            ids[i] = tokenOfOwnerByIndex(owner, i);
        }
        return ids;
    }
    struct Token {
        uint256 id;
        uint256 hash;
        string filename;
        uint256 balance;
        uint256 totalSupply;
    }
    function tokenByIdFull(uint256 tokenId) public view returns (Token memory) {
        uint256 hash = tokenIdToHash[tokenId];
        string memory filename = getMetadata(hash, "filename");
        uint256 totalSupply = hashToTotalSupply[hash];
        return Token(tokenId, hash, filename, 0, totalSupply);
    }
    function tokenOfOwnerByIndexFull(address owner, uint256 index) public view returns (Token memory) {
        uint256 tokenId = tokenOfOwnerByIndex(owner, index);
        uint256 hash = tokenIdToHash[tokenId];
        string memory filename = getMetadata(hash, "filename");
        uint256 balance = balanceOfHash(owner, hash);
        uint256 totalSupply = hashToTotalSupply[hash];
        return Token(tokenId, hash, filename, balance, totalSupply);
    }
    
    function getMetadata(uint256 hash, string memory key) public view returns (string memory) {
        for (uint256 i = 0; i < hashToMetadata[hash].length; i++) {
            if (streq(hashToMetadata[hash][i].key, key)) {
                return hashToMetadata[hash][i].value;
            }
        }
        return "";
    }
    function setMetadata(uint256 hash, string memory key, string memory value) public {
        require(isCollaborator(hash, msg.sender), "not a collaborator");
        
        bool keyFound = false;
        for (uint256 i = 0; i < hashToMetadata[hash].length; i++) {
            if (streq(hashToMetadata[hash][i].key, key)) {
                hashToMetadata[hash][i].value = value;
                keyFound = true;
                break;
            }
        }
        if (!keyFound) {
            hashToMetadata[hash].push(Metadata(key, value));
        }
    }
    function updateHash(uint256 oldHash, uint256 newHash) public {
        require(hashToTotalSupply[oldHash] > 0, "old hash does not exist");
        require(hashToTotalSupply[newHash] == 0, "new hash already exists");
        require(isCollaborator(oldHash, msg.sender), "not a collaborator");

        uint256 startTokenId = hashToStartTokenId[oldHash];
        uint256 totalSupply = hashToTotalSupply[oldHash];
        for (uint256 i = 0; i < totalSupply; i++) {
            tokenIdToHash[i] = startTokenId + i;
        }

        hashToStartTokenId[newHash] = hashToStartTokenId[oldHash];
        hashToTotalSupply[newHash] = hashToTotalSupply[oldHash];
        hashToMetadata[newHash] = hashToMetadata[oldHash];
        hashToCollaborators[newHash] = hashToCollaborators[oldHash];

        delete hashToStartTokenId[oldHash];
        delete hashToTotalSupply[oldHash];
        delete hashToMetadata[oldHash];
        delete hashToCollaborators[oldHash];
    }
}
