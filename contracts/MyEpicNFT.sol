// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract MyEpicNFT is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  mapping (address => uint) private NFTsOwned;
  mapping (uint => string) private tokenURIs;

  // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
  // So, we make a baseSvg variable here that all our NFTs can use.
  string svgPartOne = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill:"; 
  string svgPartTwo = "; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
  string svgPartThree = "'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

  // I create three arrays, each with their own theme of random words.
  // Pick some random funny words, names of anime characters, foods you like, whatever! 
  string[] firstWords = ["1FT", "2FT", "3FT", "4FT", "5FT", "6FT", "7FT", "8FT", "9FT", "10FT", "11FT", "12FT", "13FT", "14FT", "15FT", "16FT"];
  string[] secondWords = ["PURPLE", "GREEN", "BLUE", "RED", "WHITE", "BROWN", "YELLOW", "CYAN", "PINK", "ORANGE", "BLACK", "GREEN", "TRANSPARENT", "MAROON", "GRAY", "TEAL"];
  string[] thirdWords = ["ALAIA", "SKIMBOARD", "BODYBOARD", "WAKEBOARD", "LONGBOARD", "SHORTBOARD", "MIDLENGTH", "FUNBOARD", "HANDPLANE", "WAVESTORM", "GUN", "PADDLEBOARD", "FISH", "HYBRID", "HULL", "EGG"];

   // Get fancy with it! Declare a bunch of colors.
  string[] backColors = ["red", "#08C2A8", "black", "yellow", "blue", "green"];
  string[] fontColors = ["purple", "orange", "brown"];

  // MAGICAL EVENTS.
  event NewEpicNFTMinted(address sender, uint256 tokenId);

  // We need to pass the name of our NFTs token and it's symbol.
  constructor() ERC721 ("SquareNFT", "SQUARE") {
    console.log("This is my NFT contract. Woah!");
  }

  // I create a function to randomly pick a word from each array.
  function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % firstWords.length;
    return firstWords[rand];
  }
    // I create a function to randomly pick a word from each array.
  function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % secondWords.length;
    return secondWords[rand];
  }
    // I create a function to randomly pick a word from each array.
  function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % thirdWords.length;
    return thirdWords[rand];
  }

  function pickRandomColorBack(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("BACKCOLOR", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % backColors.length;
    return backColors[rand]; 
  }

  function pickRandomColorFont(uint256 tokenId) public view returns (string memory) {
    // I seed the random generator. More on this in the lesson. 
    uint256 rand = random(string(abi.encodePacked("FONTCOLOR", Strings.toString(tokenId))));
    // Squash the # between 0 and the length of the array to avoid going out of bounds.
    rand = rand % fontColors.length;
    return fontColors[rand]; 
  }

  function random(string memory input) internal pure returns (uint256) {
    return uint256(keccak256(abi.encodePacked(input)));
  }

  // A function our user will hit to get their NFT.
  function makeAnEpicNFT() public {
    // Get the current tokenId, this starts at 0.
    require(NFTsOwned[msg.sender] < 2, "Cannot mint more than 2 NFTs, go to the second market!!");
    uint256 newItemId = _tokenIds.current();

    // We go and randomly grab one word from each of the three arrays.
    string memory first = pickRandomFirstWord(newItemId);
    string memory second = pickRandomSecondWord(newItemId);
    string memory third = pickRandomThirdWord(newItemId);
    string memory background = pickRandomColorBack(newItemId);
    string memory font = pickRandomColorFont(newItemId);
    string memory combinedWord = string(abi.encodePacked(first, second, third));

    string memory finalSvg = string(abi.encodePacked(svgPartOne, font, svgPartTwo, background, svgPartThree, combinedWord, "</text></svg>"));

    // Get all the JSON metadata in place and base64 encode it.
    string memory json = Base64.encode(
        bytes(
            string(
                abi.encodePacked(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        )
    );

    // Just like before, we prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );

    console.log("\n--------------------");
    console.log(finalTokenUri);
    console.log("--------------------\n");

     // Actually mint the NFT to the sender using msg.sender.
    _safeMint(msg.sender, newItemId);

    // Set the NFTs data.
    _setTokenURI(newItemId, finalTokenUri);

    NFTsOwned[msg.sender] = NFTsOwned[msg.sender] + 1;
  
    // Increment the counter for when the next NFT is minted.
    _tokenIds.increment();
    console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

    console.log("%s owns %s NFTS", msg.sender, NFTsOwned[msg.sender]);

    // EMIT MAGICAL EVENTS.
    emit NewEpicNFTMinted(msg.sender, newItemId);
  }
}