// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyNFT is ERC721 {

    mapping(address => uint[]) public ownerTokens;
    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    uint public maxSupply = 28;

    uint public totalSupply;
    

    event Minted (uint tokenId, address minter);


    function mint() external {
        require(totalSupply < maxSupply, "max supply reached");
        uint tokenId = ++totalSupply;
        _safeMint(msg.sender, tokenId);
        ownerTokens[msg.sender].push(tokenId);
        emit Minted (tokenId, msg.sender);
    }

    function ownerTokensLength(address _owner) public view returns(uint256) {
        return ownerTokens[_owner].length;
    }


    function _baseURI() internal view override returns(string memory) {
        return "";
    }

     

  
}