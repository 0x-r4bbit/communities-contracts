// SPDX-License-Identifier: Mozilla Public License 2.0
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectibleV1 is
    Context,
    ERC721Enumerable,
    Ownable
{
    using Counters for Counters.Counter;

    // State variables

    Counters.Counter private _tokenIdTracker;

    /**
     * If we want unlimited total supply we should set maxSupply to 2^256-1.
     */
    uint256 public maxSupply;

    /**
     * If set to true, the contract owner can burn any token.
     */
    bool public remoteBurnable;

    /**
     * If set to false it acts as a soulbound token.
     */
    bool public transferable;

    string public baseTokenURI;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        bool _remoteBurnable,
        bool _transferable,
        string memory _baseTokenURI
    ) ERC721(_name, _symbol) {
        maxSupply = _maxSupply;
        remoteBurnable = _remoteBurnable;
        transferable = _transferable;
        baseTokenURI = _baseTokenURI;
    }

    // Events

    // External functions

    function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
        require(newMaxSupply >= totalSupply(), "MAX_SUPPLY_LOWER_THAN_TOTAL_SUPPLY");
        maxSupply = newMaxSupply;
    }

    /**
     * @dev Creates a new token for each address in `addresses`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     */
    function mintTo(address[] memory addresses) external onlyOwner {
        // We cannot just use totalSupply() to create the new tokenId because tokens
        // can be burned so we use a separate counter.
        require(_tokenIdTracker.current() + addresses.length < maxSupply, "MAX_SUPPLY_REACHED");

        for (uint256 i = 0; i < addresses.length; i++) {
            _safeMint(addresses[i], _tokenIdTracker.current(), "");
            _tokenIdTracker.increment();
        }
    }

    // Public functions

    /**
     * @notice remoteBurn allows the owner to burn a token
     * @param tokenIds The list of token IDs to be burned
     */
    function remoteBurn(uint256[] memory tokenIds) public onlyOwner {
        require(remoteBurnable, "NOT_REMOTE_BURNABLE");

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _burn(tokenIds[i]);
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Internal functions

    /**
     * @notice
     * @dev
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    /**
     * @notice
     * @dev
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override(ERC721Enumerable) {
        if (from != address(0) && to != address(0) && !transferable) {
            revert("not transferable");
        }
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    // Private functions
}
