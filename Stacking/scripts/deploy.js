const hre = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  const Token = await hre.ethers.getContractFactory("TokenOne");
  const token = await Token.deploy();
  await token.deployed();

  console.log(`owner address: ${owner.address}`);

  console.log(`Deployed token address: ${token.address}`);

  const WAIT_BLOCK_CONFIRMATIONS = 6;
  await token.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);

  console.log(`Contract REC20 deployed to ${token.address} on ${network.name}`);

  const TokenUSDT = await hre.ethers.getContractFactory("USDT");
  const tokenUSDT = await TokenUSDT.deploy();
  await tokenUSDT.deployed();

  console.log(`owner address: ${owner.address}`);

  console.log(`Deployed token address: ${tokenUSDT.address}`);

  await tokenUSDT.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);

  console.log(
    `Contract USDT deployed to ${tokenUSDT.address} on ${network.name}`
  );

  const TokenStaking = await hre.ethers.getContractFactory("Staking");
  const tokenStaking = await TokenStaking.deploy(
    token.address,
    tokenUSDT.address,
    1000,
    1
  );
  await tokenStaking.deployed();

  console.log(`owner address: ${owner.address}`);

  console.log(`Deployed token address: ${tokenStaking.address}`);

  await tokenStaking.deployTransaction.wait(WAIT_BLOCK_CONFIRMATIONS);

  console.log(
    `Contract stacking deployed to ${tokenStaking.address} on ${network.name}`
  );

  console.log(`Verifying contract ERC20 on Etherscan...`);

  await hre.run(`verify:verify`, {
    address: token.address,
    constructorArguments: [],
  });

  console.log(`Contract ERC20 is verifyed`);

  console.log(`Verifying contract USDT on Etherscan...`);

  await hre.run(`verify:verify`, {
    address: tokenUSDT.address,
    constructorArguments: [],
  });

  console.log(`Contract USDT is verifyed`);

  console.log(`Verifying contract Staking on Etherscan...`);

  await hre.run(`verify:verify`, {
    address: tokenStaking.address,
    constructorArguments: [token.address, tokenUSDT.address, 1000, 1],
  });

  console.log(`Contract Stacking is verifyed`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
