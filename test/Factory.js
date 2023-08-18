const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotableTransactionFactory contract", async function () {


    async function deployFixture() {
        const [signer1, signer2] = await ethers.getSigners();

        const contractFactory = await ethers.getContractFactory("MultiSigVoter");
        const factory = await contractFactory.deploy([signer1.address, signer2.address], 2);
        return { signer1, signer2, contractFactory, factory, required: 2 };
    }


    it("Deploy contract factory", async function () {
        const { signer1, signer2, contractFactory, factory, required } = await deployFixture();
        expect(await factory.getTotalProposalsMade()).to.equal(0);
        expect(await factory.getRequiredSignatures()).to.equal(required);
    });

    it("Propose Transaction", async function () {
        const { signer1, signer2, contractFactory, factory, required } = await deployFixture();

        // Call 'ProposeTransaction' function and get the address of the new contract
        expect(await factory.getTotalProposalsMade()).to.equal(0);
        const proposal = await factory.proposeTransaction(signer1.address, 20);
        const receipt = await proposal.wait();
        expect(await factory.getTotalProposalsMade()).to.equal(1);

        // Expect the address of the newly created contract to be emitted and not be 0x0 or null
        const proposalAddress = receipt.events[0].args[0];
        expect(proposalAddress).to.not.equal(0x0);
        expect(proposalAddress).to.not.equal(null);

        // Expect 'GetVotes' function to return 0 from proposalAddress
        const proposalContract = await ethers.getContractAt("TransactionContract", proposalAddress);
        expect(await proposalContract.getVotes()).to.equal(0);

        // Cast a vote from signer1
        await proposalContract.connect(signer1).vote();
        expect(await proposalContract.getVotes()).to.equal(1);

        // Ensure that signer1 can not cast another vote
        await expect(proposalContract.connect(signer1).vote()).to.be.revertedWith("Sender has already voted");

        // Ensure that payout can not be called before the required number of votes are cast
        await expect(proposalContract.connect(signer1).payout()).to.be.revertedWith("Not enough votes");

        // Cast a vote from signer2
        await proposalContract.connect(signer2).vote();
        expect(await proposalContract.getVotes()).to.equal(2);

        // Get the balance of the contract before payout
        const balanceBefore = await ethers.provider.getBalance(proposalAddress);
        console.log("Balance before payout: ", balanceBefore.toString());

        // Ensure that 'Not enough funds to payout' is thrown if the contract does not have enough funds
        await expect(proposalContract.connect(signer1).payout()).to.be.revertedWith("Not enough funds to payout");

        // Deposit funds into the contract
        await signer1.sendTransaction({ to: proposalAddress, value: 100 });

        // Call payout function
        await proposalContract.payout();


    });

});
