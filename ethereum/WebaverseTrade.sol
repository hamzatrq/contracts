// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./WebaverseERC20.sol";
import "./WebaverseERC721.sol";

/** @title Webaverse Trade Contract
 * @dev Trade contract to manage user to user trading of fungible and non-fungible tokens
 */
contract WebaverseTrade {
    struct Store {
        uint256 id;
        address seller;
        uint256 tokenId;
        uint256 price;
        bool live;
    }
    event Sell(
        uint256 indexed id,
        address indexed seller,
        uint256 indexed tokenId,
        uint256 price
    );
    event Unsell(uint256 indexed id);
    event Buy(uint256 indexed id);

    WebaverseERC20 parentERC20; // managed ERC20 contract
    WebaverseERC721 parentERC721; // managed ERC721 contract
    address signer; // signer oracle address
    uint256 nextBuyId; // next buy id
    mapping(uint256 => Store) stores;

    /**
     * @dev Construct the contract with managed ERC20 and ERC721 contryacts
     * @param parentERC20Address Address of the managed ERC20 contract
     * @param parentERC721Address Address of the managed ERC721 contract
     * @param signerAddress Address of an authorized signer
     * Default parentERC20Address address: 0xd7523103ba15c1dfcf0f5ea1c553bc18179ac656
     * Default parentERC721Address address: 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4
     */
    // 0xd7523103ba15c1dfcf0f5ea1c553bc18179ac656
    // 0xfa80e7480e9c42a9241e16d6c1e7518c1b1757e4
    constructor(
        address parentERC20Address,
        address parentERC721Address,
        address signerAddress
    ) public {
        parentERC20 = WebaverseERC20(parentERC20Address);
        parentERC721 = WebaverseERC721(parentERC721Address);
        signer = signerAddress;
        nextBuyId = 0;
    }

    /** @dev Set the address for the signer oracle
     * @param newSigner Address of the new signer
     */
    function setSigner(address newSigner) public {
        require(
            msg.sender == signer,
            "new signer can only be set by old signer"
        );
        signer = newSigner;
    }

    /** @dev Set the parent ERC20 contract that this contract manages
     * @param newParentERC20 Address of parent contract
     */
    function setERC20Parent(address newParentERC20) public {
        require(msg.sender == signer, "must be signer");
        parentERC20 = WebaverseERC20(newParentERC20);
    }

    /** @dev Set the ERC721 contract that this contract manages
     * @param newParentERC721Address Address of parent contract
     */
    function setERC721Parent(address newParentERC721Address) public {
        require(msg.sender == signer, "must be signer");
        parentERC721 = WebaverseERC721(newParentERC721Address);
    }

    /** @dev Add a non-fungible token to the store to be sold
     * @param tokenId Token to sell
     * @param price Price to sell token for
     */
    function addStore(uint256 tokenId, uint256 price) public {
        uint256 buyId = ++nextBuyId;
        stores[buyId] = Store(buyId, msg.sender, tokenId, price, true);

        emit Sell(buyId, msg.sender, tokenId, price);

        address contractAddress = address(this);
        parentERC721.transferFrom(msg.sender, contractAddress, tokenId);
    }

    /** @dev Remove a token from the store for sale
     * @param buyId ID of the asset in the store
     */
    function removeStore(uint256 buyId) public {
        Store storage store = stores[buyId];
        require(store.seller == msg.sender, "not your sale");
        require(store.live, "sale not live");
        store.live = false;

        emit Unsell(buyId);

        address contractAddress = address(this);
        parentERC721.transferFrom(contractAddress, store.seller, store.tokenId);
    }

    /** @dev Purchase a token for sale
     * @param buyId ID of the asset in the store
     */
    function buy(uint256 buyId) public {
        Store storage store = stores[buyId];
        require(store.live, "sale not live");
        store.live = false;

        emit Buy(buyId);

        parentERC20.transferFrom(msg.sender, store.seller, store.price);
        address contractAddress = address(this);
        parentERC721.transferFrom(contractAddress, msg.sender, store.tokenId);
    }

    /** @dev Get the number of stored assets by the next available ID
     * @return Next usable buy ID, which is an incremented counter
     */
    function numStores() public view returns (uint256) {
        return nextBuyId;
    }

    /** @dev Get the stored value by buyID
     * @param buyId ID of the asset in the store
     * @return Value in the store keyed by buyId
     */
    function getStoreByIndex(uint256 buyId) public view returns (Store memory) {
        return stores[buyId];
    }

    /** @dev Trade assets between users
     * @param from ID of player A
     * @param to ID of player B
     * @param fromFt Amount of ERC20 tokens player A has committed to trade
     * @param toFt Amount of ERC20 tokens player B has committed to trade
     * @param a1 Item 1 in player A's trade window
     * @param b1 Item 1 in player B's trade window
     * @param a2 Item 2 in player A's trade window
     * @param b2 Item 2 in player B's trade window
     * @param a3 Item 3 in player A's trade window
     * @param b3 Item 3 in player B's trade window
     */
    function trade(
        address from,
        address to,
        uint256 fromFt,
        uint256 toFt,
        uint256 a1,
        uint256 b1,
        uint256 a2,
        uint256 b2,
        uint256 a3,
        uint256 b3
    ) public {
        require(msg.sender == signer, "unauthorized signer");
        if (fromFt != 0)
            require(
                parentERC20.transferFrom(from, to, fromFt),
                "transfer ft from -> to failed"
            );
        if (toFt != 0)
            require(
                parentERC20.transferFrom(to, from, toFt),
                "transfer ft from <- to failed"
            );
        if (a1 != 0) parentERC721.transferFrom(from, to, a1);
        if (b1 != 0) parentERC721.transferFrom(to, from, b1);
        if (a2 != 0) parentERC721.transferFrom(from, to, a2);
        if (b2 != 0) parentERC721.transferFrom(to, from, b2);
        if (a3 != 0) parentERC721.transferFrom(from, to, a3);
        if (b3 != 0) parentERC721.transferFrom(to, from, b3);
    }
}
