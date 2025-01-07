const {
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Factory", function () {
  const FEE = ethers.parseUnits("0.001", 18);

  async function deployFactoryFixture() {
    const [deployer, creator] = await ethers.getSigners();

    const Factory = await ethers.getContractFactory("Factory");
    // Deploy contract
    const factory = await Factory.deploy(FEE);

    const transaction = await factory
      .connect(creator)
      .create("Diego Tokne", "DT", { value: FEE });

    await transaction.wait();

    const tokenAddress = await factory.tokens(0);
    const token = await ethers.getContractAt("Token", tokenAddress);
    return { factory, token, deployer, creator };
  }

  describe("Deployment", function () {
    it("Should set the fee", async function () {
      const { factory } = await loadFixture(deployFactoryFixture);
      expect(await factory.fee()).to.equal(FEE);
    });
    it("Should set the owner", async function () {
      const { factory, deployer } = await loadFixture(deployFactoryFixture);
      expect(await factory.owner()).to.equal(deployer.address);
    });
  });

  describe("Creating", function () {
    it("Should set the owner", async function () {
      const { factory, token } = await loadFixture(deployFactoryFixture);
      expect(await token.owner()).to.equal(await factory.getAddress());
    });
  });
});
