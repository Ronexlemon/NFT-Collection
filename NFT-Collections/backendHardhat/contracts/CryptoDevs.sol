// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../node_modules/@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./Iwhitelist.sol";



contract CryptoDevs is ERC721Enumerable, Ownable {
    
string _baseTokenURI;
//_price is the price of one nft
uint public _price =0.01 ether;
//paused the contract incase of an issue
bool public _paused;
//max number of crypto devs
uint public maxTokensId = 20;
//total number of tokens minted
uint public tokensIds;
//whitelist contract instance
IWhitelist whitelist;
//keepig track of whether presale started or not
bool public presaleStarted;
//timestap for when presale ended
uint public presaleEnded;

modifier onlyWhenNotPaused{
    require(!_paused,"Contract currently paused");
    _;
}

  /**
       * @dev ERC721 constructor takes in a `name` and a `symbol` to the token collection.
       * name in our case is `Crypto Devs` and symbol is `CD`.
       * Constructor for Crypto Devs takes in the baseURI to set _baseTokenURI for the collection.
       * It also initializes an instance of whitelist interface.
       */

       constructor(string memory baseURI,address whitelistContract) ERC721("Crypto Devs","CD"){
_baseTokenURI = baseURI;
whitelist = IWhitelist(whitelistContract);
       }

//starts a presale for the whitelisted address
function startPresale()public onlyOwner {
    presaleStarted = true;
    //set presale  time to current timesatmp + 5 minutes
    presaleEnded = block.timestamp + 5 minutes;

}
//presalemint  allows a user to mint one NFT per Transaction during the presale window
function presaleMint() public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp < presaleEnded,"Presale is not running");
    require(whitelist.whitelistedAddresses(msg.sender),"You're not whitelisted");
    require(tokensIds < maxTokensId,"Exceed maximum Crypto Supply");
    require(msg.value >= _price,"Ether send is not correct");
    tokensIds +=1;
    _safeMint(msg.sender, tokensIds);


}
/**
*@dev mint allows a user to mint 1 NFT per Transaction after the presale has ended

 */
 function mint()public payable onlyWhenNotPaused{
    require(presaleStarted && block.timestamp >= presaleEnded,"Presale has not ended yet");
    require(tokensIds < maxTokensId,"Exceed maximum crypto suply");
    require(msg.value >=_price,"Ether not Correct");
    tokensIds +=1;
    _safeMint(msg.sender, tokensIds);

 }
 /**
      * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
      * returned an empty string for the baseURI
      */
      function _baseURI() internal view virtual override returns(string memory){
        return _baseTokenURI;

      }
      // setpaused makes the contract paused or unpaused
      function setPaused(bool val) public onlyOwner{
        _paused = val;
      }
      /**
      *@dev withdraw sends all the ether in the contract to the owner of the contract

       */
       function withdraw()public onlyOwner{
        address _owner = owner();
        uint amount = address(this).balance;
        (bool  sent,) = _owner.call{value:amount}("");
        require(sent,"failed to send Ether");
       }
       //function to receive ether, msg,data must be empty
       receive() external payable{}
       //fallback is called when msg.data !empty
       fallback() external payable{}

 }
