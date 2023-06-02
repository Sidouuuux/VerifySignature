const { expect } = require("chai");

describe("VerifySignature", function () {
  let Contract;
  let contract;
  let owner;
  let addr1;
  let message = "Hello World";
  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();

    Contract = await ethers.getContractFactory("VerifySignature");
    contract = await Contract.deploy();
    await contract.deployed();
  });
});
