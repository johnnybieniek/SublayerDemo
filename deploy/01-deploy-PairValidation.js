const { network } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config.js")
const { verify } = require("../utils/verify")
const fs = require("fs")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    // let tokenURIs

    // if (process.env.PINATA_UPLOAD == "true") {
    //     tokenURIs = await handleTokenUris()
    // }

    log("----------------------------------------------------")
    arguments = []
    const pairValidation = await deploy("PairValidation", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    // Verify the deployment
    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        log("Verifying...")
        await verify(pairValidation.address, arguments)
    }
}

module.exports.tags = ["all", "pairvalidation", "main"]

// function handleTokenUris() {
//     tokenUris = []

//     return tokenUris
// }
