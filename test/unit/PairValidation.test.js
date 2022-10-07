const { assert, expect } = require("chai")
const { network, deployments, ethers } = require("hardhat")
const { developmentChains } = require("../../helper-hardhat-config.js")

describe("PairValidation Unit Tests", function () {
    let pairValidation, deployer, account1
    let uriS =
        '{"name":"Pair Programming","description":"Pair Programming token for Jan Bieniek with Scott Werner","attributes":[{"trait_type":"Sublayer NFTs early user","value":404}],"image":"ipfs://QmT6ucfKptoW9VxriBHPmBRatoSVPuyYHa57uWNWxzaW3D"}'

    beforeEach(async () => {
        accounts = await ethers.getSigners()
        deployer = accounts[0]
        account1 = accounts[1]
        await deployments.fixture(["pairvalidation"])
        pairValidation = await ethers.getContract("PairValidation")
    })

    describe("Constructor", async function () {
        it("Initializes the constructor properly", async function () {
            const tokenCounter = await pairValidation.getTokenCounter()
            assert.equal(tokenCounter, 0)
            const mappingSize = await pairValidation.getMappingSize()
            assert.equal(mappingSize, 0)
        })
    })
    describe("Submit request for Nft", async function () {
        it("Emits an event after a request is submitted", async function () {
            expect(
                await pairValidation.submitRequestForNft(
                    account1.address,
                    "Jan Bieniek",
                    "Scott Werner",
                    2
                )
            ).to.emit("RequestSubmitted")
        })
        it("Checks if the previously request exists", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            const request = await pairValidation.getNftRequest(account1.address)
            const exist = request.exist
            assert.equal("1", exist.toString())
        })
        it("Checks if the requestor address is correct", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            const request = await pairValidation.getNftRequest(account1.address)
            const requestor = request.requestorAddress
            assert.equal(requestor, deployer.address)
        })
        it("Increases mapping size by 1", async function () {
            const mappingSize1 = await pairValidation.getMappingSize()
            assert.equal(mappingSize1, 0)
            await pairValidation.submitRequestForNft(``
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            const mappingSize2 = await pairValidation.getMappingSize()
            assert.equal(mappingSize2, 1)
        })
        it("Declines the submission of a duplicate request", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            await expect(
                pairValidation.submitRequestForNft(
                    account1.address,
                    "Jan Bieniek",
                    "Scott Werner",
                    2
                )
            ).to.be.revertedWith("PairValidation__DuplicateRequest")
        })
    }) // end of SubmitRequest
    describe("Accept Nft", async function () {
        it("User successfully accepts a previously requested NFT and emits event", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            pairValidation = await pairValidation.connect(account1)
            expect(await pairValidation.acceptNft()).to.emit("NftMinted")
        })
        it("User successfully accepts an NFT and increases token counter by 2", async function () {
            const tokenCounter1 = await pairValidation.getTokenCounter()
            assert.equal(tokenCounter1, 0)
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            pairValidation = await pairValidation.connect(account1)
            await pairValidation.acceptNft()
            const tokenCounter2 = await pairValidation.getTokenCounter()
            assert.equal(tokenCounter2, 2)
        })
        it("User successfully accepts a previously requested NFT and has the right token URI", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            pairValidation = await pairValidation.connect(account1)
            await pairValidation.acceptNft()
            const tokenUri = await pairValidation.getTokenURI(1)
            assert.equal(tokenUri, uriS)
        })
        it("Decreases mapping size by 1 when an Nft is minted", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            const mappingSize2 = await pairValidation.getMappingSize()
            assert.equal(mappingSize2, 1)
            pairValidation = await pairValidation.connect(account1)
            await pairValidation.acceptNft()
            const mappingSize1 = await pairValidation.getMappingSize()
            assert.equal(mappingSize1, 0)
        })
        it("Reverts when a user tries to accept a non-existent NFT request", async function () {
            await expect(pairValidation.acceptNft()).to.be.revertedWith(
                "PairValidation__NothingToAccept"
            )
        })
    })
    describe("TokenURI", async function () {
        it("returns the tokenURI", async function () {
            await pairValidation.submitRequestForNft(
                account1.address,
                "Jan Bieniek",
                "Scott Werner",
                2
            )
            pairValidation = await pairValidation.connect(account1)
            await pairValidation.acceptNft()
            const tokenURI = await pairValidation.getTokenURI(1)
            console.log(tokenURI)
        })
    })
})
