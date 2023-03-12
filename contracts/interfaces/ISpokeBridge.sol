// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// FIXME comments
/**
 * @notice This interface will send and receive messages through.
 */
interface ISpokeBridge {

    /**
     * @dev Status of a bid:
     *      0 - FIXME
     */
    enum BidStatus {
        None,
        Created,
        Bought,
        Challenged,
        Done
    }

    struct Bid {
        uint256 id;
        BidStatus status;
        uint16 fee; //FIXME it is questionable
        address maker;
        address receiver;
        uint256 tokenId;
        address erc721Contract;
        uint32 chainId;
        uint256 timeOfBuying; // FIXME better name
        address buyer;
    }

    /**
     * @dev Status of a bid:
     *      0 - FIXME
     */
    enum RelayerStatus {
        None,
        Active,
        Undeposited,
        Challenged,
        Malicious
    }

    struct Relayer {
        RelayerStatus status;
        uint dateOfUndeposited;
        uint256 stakedAmount; // TODO make linear relationship beetween the number of interactions and staked amount
        // TODO use versioning
    }

    // TODO define the parameters of the BID
    event BidCreated();

    event BidBought(address relayer, uint256 bidId);

    event BidChallenged(address challenger, address relayer, uint256 bidId);

    // TODO define the parameters of the proof
    event ProofSent();

    event NFTUnwrapped(address contractAddress, uint256 bidId, uint256 id, address owner);

    function createBid(address _receiver, uint256 _tokenId, address _erc721Contract, uint32 _chainId) external payable;

    function buyBid(uint256 _bidId) external;

    function sendProof(uint256 _bidId) external;

    function receiveProof(uint256 _bidId) external;

    function deposite() external payable;

    function undeposite() external;

    function claimDeposite() external;
}