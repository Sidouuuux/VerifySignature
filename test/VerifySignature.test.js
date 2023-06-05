const { expect } = require("chai");

describe("VerifySignature", function () {
  let Contract;
  let contract;
  let owner;
  let addr1;
  let message = "Hello World";
  beforeEach(async function () {
    const accounts = await ethers.getSigners(2);

    Contract = await ethers.getContractFactory("VerifySignature");
    contract = await Contract.deploy();
    await contract.deployed();
  });

  it("Check signature", async function () {
    const accounts = await ethers.getSigners(2);

    // const PRIV_KEY = "0x..."
    // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0];
    const message = "Hello";

    const hash = await contract.getMessageHash(message);
    const sig = await signer.signMessage(ethers.utils.arrayify(hash));

    const ethHash = await contract.getEthSignedMessageHash(hash);

    console.log("signer          ", signer.address);
    console.log("recovered signer", await contract.recoverSigner(ethHash, sig));

    expect(await contract.verify(signer.address, message, sig)).to.equal(true);
  });

  it("Check incorrect signature", async function () {
    const accounts = await ethers.getSigners(2);

    // const PRIV_KEY = "0x..."
    // const signer = new ethers.Wallet(PRIV_KEY)
    const signer = accounts[0];
    const message = "Hello";

    const hash = await contract.getMessageHash(message);
    const sig = await signer.signMessage(ethers.utils.arrayify(hash));

    const ethHash = await contract.getEthSignedMessageHash(hash);

    console.log("signer          ", signer.address);
    console.log("recovered signer", await contract.recoverSigner(ethHash, sig));

    // Incorrect message returns false
    expect(await contract.verify(signer.address, "message", sig)).to.equal(
      false
    );
  });
  
  it("Check signature length", async function () {
    const accounts = await ethers.getSigners(2);

    const signer = accounts[0];
    const message = "Hello";

    const hash = await contract.getMessageHash(message);
    const sig = await signer.signMessage(ethers.utils.arrayify(hash));

    // Modify the signature length to be less than 65
    const modifiedSig = sig.slice(0, 64);

    // Verify that the contract reverts with the expected error message
    await expect(
      contract.verify(signer.address, message, modifiedSig)
    ).to.be.revertedWith("invalid signature length");
  });
});
