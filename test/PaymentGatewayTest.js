
const { parseEther } = require("@ethersproject/units");
const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("TheGameHub", function () {
  let hub,paymentLibrary, owner, addr1, addr2;
  beforeEach(async ()=>{
    [owner, addr1, addr2] = await ethers.getSigners();

    //import hub and link to library
    const Hub = await hre.ethers.getContractFactory("TheGameHub");
    hub = await Hub.deploy(addr1.address);
    await hub.deployed();

  })

  it("sets new promotional discount", async () => {
    expect((await hub.getPromotionalDiscount()).discountPercent)
    .to.equal(0)

    const newPercent = 50
    const daysForPromotionToLast = 5

    await hub.setPromotionalDiscount(newPercent, daysForPromotionToLast)

    expect((await hub.getPromotionalDiscount()).discountPercent)
    .to.equal(newPercent)

  });

  it("set easy game master price", async () => {
    expect(Number(await hub.getEasyGameMasterPrice()))
    .to.equal(1000)

    const newPrice = 2000;
    await hub.setEasyGameMasterPrice(newPrice)

    expect(Number(await hub.getEasyGameMasterPrice()))
    .to.equal(newPrice)
  });

  it("attempt to set address as non-owner", async () => {
    const newPrice = 2000;
    await expect(hub.connect(addr2).setEasyGameMasterPrice(newPrice))
    .to.be.revertedWith("Ownable: caller is not an owner")
  });

  it("set a promotion", async () => {
    expect((await hub.getPromotionalDiscount()).discountPercent).to.equal(0)

    const promotionPercent = 20
    const daysUntilExpiry = 2
    await expect(hub.setPromotionalDiscount(promotionPercent, daysUntilExpiry))
    .to.emit(hub, "PromotionalDiscountApplied")

    expect((await hub.getPromotionalDiscount()).discountPercent).to.equal(promotionPercent)
  });

  it("attempt to set promotion as non-owner", async () => {
    await expect(hub.connect(addr2).setPromotionalDiscount(1, 1))
    .to.be.revertedWith("Ownable: caller is not an owner")
  });

  it("attempt to pause as non-owner", async () => {
      await expect(hub.connect(addr2).pause())
      .to.be.revertedWith("Ownable: caller is not an owner")
  });

  it("attempt to buy gamemaster when paused", async () => {
    expect(await hub.paused())
    .to.equal(false)

    await hub.pause()

    expect(await hub.paused())
    .to.equal(true)

    await expect(hub.buyEasyGameMaster())
    .to.be.revertedWith("Pausable: paused")

  });

  it("attempt to buy easy gamemaster", async () => {
    const newPrice = 1;
    await hub.setEasyGameMasterPrice(newPrice)

    const price = await hub.getEasyGameMasterPrice()

    expect(await hub.buyEasyGameMaster({value:parseEther(String(price))}))

  });


});


/*
const { ethers, waffle} = require("hardhat");
const provider = waffle.provider;
const balance0ETH = await provider.getBalance(user1.address);
---------
const time = now + 86400
await ethers.provider.send('evm_setNextBlockTimestamp', [now]); 
await ethers.provider.send('evm_mine');


-----

// suppose the current block has a timestamp of 01:00 PM
await network.provider.send("evm_increaseTime", [3600])
await network.provider.send("evm_mine") // this one will have 02:00 PM as its timestamp

------

await network.provider.send("evm_setNextBlockTimestamp", [1625097600])
await network.provider.send("evm_mine") // this one will have 2021-07-01 12:00 AM as its timestamp, no matter what the previous block has

------

await ethers.provider.getBlockNumber().then((blockNumber) => {
      console.log("Current block number: " + blockNumber);
    });
 */