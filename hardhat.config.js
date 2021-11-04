require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks:{
    ganache:{
      url:"http://127.0.0.1:7545",
      acccounts: ["e2b021e58dd2deef23162418cb49af66152721827e3c338ca60b25b37e8c9757"]
    }
  },
  solidity: "0.8.5",
};
