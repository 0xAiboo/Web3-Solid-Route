process.stdout.setEncoding('utf8');
const { MerkleTree } = require('merkletreejs');
const keccak256 = require("keccak256");

const whiteList = [
    { address: "0x4b5EF7cA580Db6f98D794A1b78d56773Bc83F9D3", amount: 3 },
    { address: "0x2FD427F265F9546183cac875Db9e0e6d00FC7d8A", amount: 1 },
    { address: "0x9c67Bc18497BB77E1Ba9DeD3178671fd821d4D05", amount: 4 },
    { address: "0xff8885081E7Bc7f42Ccb9cc69160E9179BF06bd6", amount: 5 },
    { address: "0x4C81345216bd11028Fc829C14880ae7d1cB69CDA", amount: 6 },
    { address: "0xC7cd4bb7bf04D937c9884F53f79A6193090b812C", amount: 2 },
    { address: "0x7639D365984941e6C82d32f61ae40e8C925440b6", amount: 2 },
    { address: "0xf7F8d93ad9C069e665CC7dC9a33F506331CCD3Dc", amount: 1 },
    { address: "0xb0950e2c9e309D725a67Fa65F3d40F38d966a878", amount: 1 }
]

const leafNodes = whiteList.map(item => keccak256(item.address));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true });
const hash = merkleTree.getRoot();
console.log("whiteList\n", hash.toString('hex'));

const cc = leafNodes[1];
const hexProof = merkleTree.getHexProof(cc);
console.log(hexProof.toString());
