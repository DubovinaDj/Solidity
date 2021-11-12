import { Contract } from '@ethersproject/contracts';
import { expect } from 'chai';
import { ethers } from 'hardhat';
import { MockProvider } from 'ethereum-waffle';
import { Signer } from 'ethers';
import { SSL_OP_MICROSOFT_SESS_ID_BUG } from 'constants';
//import { equal } from 'assert/strict';



const provider = new MockProvider();

//contract('Donation', function () {
    //const [ owner, other ] = accounts;

describe('Contract Donation tests', async () => {
    let donation: Contract;
    let nft: Contract;
    let accounts: Signer[];

    beforeEach(async ()  => {
        accounts = await ethers.getSigners()
        const donationFactory = await ethers.getContractFactory('Donation');
        const nftFactory = await ethers.getContractFactory('NFT');
        donation = await donationFactory.deploy();
        nft = await nftFactory.deploy();
        await donation.deployed();
        await nft.deployed();
    });

    it('should be callable only by admin', async function () {
        const admin = await accounts[0].getAddress();

        expect(admin).to.equal(await donation.owner());
    });

    it('changes owner after transfer', async () => {
        const admin = await accounts[0].getAddress();
        const other = await accounts[1].getAddress();
        await donation.transferOwnership(other, { from: admin});

        expect(other).to.be.equal(await donation.owner());
    });


    it('loses owner after renouncement', async () => {
        const admin = await accounts[0].getAddress();
        await donation.renounceOwnership({ from: admin });
        const zero_address = '0x0000000000000000000000000000000000000000';

        expect(zero_address).to.equal(await donation.owner());
    });

    it('should be set address', async () => {
        const newAddress = await accounts[4].getAddress();
        await donation.setNFTAddress(newAddress);
        const getAddress = await donation.getNFTAddress();

        expect(getAddress).to.equal(newAddress);
    });

    it('should be test for campaigns counter', async () => {
        await donation.createCampaign('Hmm', 'hmm', 111, 111);
        await donation.createCampaign('Hej', 'hej', 111, 111);
        const counterCampaigns = await donation.Index()

        expect(2).to.equal(counterCampaigns);
    });

    
    it('test, is campaings complete', async() => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.createCampaign('Hmm', 'hmm', 111, 10000);
        await donation.createCampaign('Hej', 'hej', 111, 10000);
        await donation.setNFTAddress(nft.address);
        await donation.connect(addr1).donate(1,{ value: ethers.utils.parseEther("0.01") });
        await donation.connect(addr1).donate(2,{ value: ethers.utils.parseEther("0.000000000000001") });
        const camp1 = await donation.campaigns(1);
        const camp2 = await donation.campaigns(2);

        expect([ true ]).to.eql(camp1.slice(5))
        expect([ false ]).to.eql(camp2.slice(5))
    });

    it('expected error -> Goal achived', async() => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.createCampaign('Hmm', 'hmm', 111, 10000);
        await donation.setNFTAddress(nft.address);
        await donation.connect(addr1).donate(1,{ value: ethers.utils.parseEther("0.01") });
        await donation.connect(addr2).donate(1,{ value: ethers.utils.parseEther("1") });
    });

    it('campaign deadline should be greater than block number ', async() => {
        await donation.createCampaign('Hmm', 'hmm', 111 + await ethers.provider.getBlockNumber() , 10000);
        const blockNum = await ethers.provider.getBlockNumber();
        const deadline = 111 + await ethers.provider.getBlockNumber();
        console.log(deadline);

        expect(deadline).greaterThan(blockNum)
    });

    //NFT
    it('changes nft owner after transfer', async () => {
        const admin = await accounts[0].getAddress();
        const other = await accounts[1].getAddress();
        await nft.transferOwnership(other, { from: admin});

        expect(other).to.equal(await nft.owner());
    });

    it('test nft contract owner', async () => {
        const admin = await accounts[0].getAddress();
        expect(admin).to.equal(await nft.owner());

    });

    it('Transfer ownership from address to adress', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.createCampaign('Hmm', 'hmm', 111, 1111);
        await donation.setNFTAddress(nft.address);
        await donation.connect(owner).donate(1,{ value: ethers.utils.parseEther("0.00000001") });
        await nft.transferFrom(owner.address, addr1.address, 0);

        expect(await nft.ownerOf(0)).to.equal(addr1.address);


    });

    it('loses nft owner after renouncement', async () => {
        const admin = await accounts[0].getAddress();
        await nft.renounceOwnership({ from: admin });
        const zero_address = '0x0000000000000000000000000000000000000000';

        expect(zero_address).to.equal(await nft.owner());
    });

    
    it('Is address owns NFT', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.createCampaign('Hmm', 'hmm', 111, 1111);
        await donation.setNFTAddress(nft.address);
        await donation.connect(addr1).donate(1,{ value: ethers.utils.parseEther("0.01") });

        expect(await nft.balanceOf(addr1.address)).to.equal(1);
    });

});
