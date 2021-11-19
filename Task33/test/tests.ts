import { expect } from "chai";
import { ethers, waffle } from 'hardhat';
import { Contract } from '@ethersproject/contracts';
import exp from 'constants';
import { Signer, BigNumber } from 'ethers';


//const provider = new MockProvider();

//contract('Donation', function () {
    //const [ owner, other ] = accounts;

describe('Tested Donation and NFT contract', async () => {
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

        expect(other).to.equal(await donation.owner());
    });


    it('loses owner after renouncement', async () => {
        const admin = await accounts[0].getAddress();
        await donation.renounceOwnership({ from: admin });
        const zero_address = '0x0000000000000000000000000000000000000000';

        expect(zero_address).to.equal(await donation.owner());
    });

    it('should be set address', async () => {
        const newAddress = await accounts[4].getAddress();
        await donation.setNftAddress(newAddress);
        const getAddress = await donation.checkNftAddress();

        expect(getAddress).to.equal(newAddress);
    });

    it('should be tested campaigns counter', async () => {
        await donation.newCampaign('Hmm', 'hmm', 111, 111);
        await donation.newCampaign('Hej', 'hej', 111, 111);
        const counterCampaigns = await donation.campaignID();
        //console.log(counterCampaigns.toNumber())

        expect(2).to.equal(counterCampaigns);
    });

    
    it('should be tested is campaign completed ', async() => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 111, 10000);
        await donation.newCampaign('Hej', 'hej', 111, 10000);
        await donation.setNftAddress(nft.address);
        await donation.connect(addr1).donatePlease(1,{ value: ethers.utils.parseEther("0.01") });
        await donation.connect(addr1).donatePlease(2,{ value: ethers.utils.parseEther("0.000000000000001")});
        const camp1 = await donation.campaigns(1);
        const camp2 = await donation.campaigns(2);

        expect([ true ]).to.eql(camp1.slice(5));
        expect([ false ]).to.eql(camp2.slice(5));
    });

    it('should be tested if campaign goal achieved', async() => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 111, 10000);
        await donation.setNftAddress(nft.address);
        await donation.connect(addr1).donatePlease(1,{ value: ethers.utils.parseEther("0.01") });

        await expect(donation.connect(addr2).donatePlease(1,{ value: ethers.utils.parseEther("1") })).to.be.reverted;
    });

    it('campaign deadline should be greater than block number', async() => {
        await donation.newCampaign('Hmm', 'hmm', 111 + await ethers.provider.getBlockNumber() , 10000);
        const blockNum = await ethers.provider.getBlockNumber();
        const deadline = 111 + await ethers.provider.getBlockNumber();

        expect(deadline).greaterThan(blockNum);
    });

    it('only admin can create campaigns', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.connect(owner).newCampaign('Hmm', 'hmm', 111, 1111);
        await expect(donation.connect(addr1).newCampaign('hjo', 'jo', 111, 1111)).to.be.reverted;
    });

    it('tested if address donated some amount', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 111, 10000);
        await donation.setNftAddress(nft.address);
        await donation.connect(addr1).donatePlease(1, { value: ethers.utils.parseEther("0.01") });
        const isDonated1 = await donation.isDonor(addr1.address);
        const isDonated2 = await donation.isDonor(addr2.address);

        expect(true).to.equal(isDonated1);
        expect(false).to.equal(isDonated2);
    });

    //NFT Contract
    it('changes nft owner after transfer', async () => {
        
        const admin = await accounts[0].getAddress();
        const other = await accounts[1].getAddress();
        await nft.transferOwnership(other, { from: admin});

        expect(other).to.equal(await nft.owner());
    });

    it('tests owner of nft contract ', async () => {
        const admin = await accounts[0].getAddress();
        expect(admin).to.equal(await nft.owner());
    });

    it('transfer ownership from address to address', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 111, 1111);
        await donation.setNftAddress(nft.address);
        await donation.connect(owner).donatePlease(1,{ value: ethers.utils.parseEther("0.00000001") });
        await nft.transferFrom(owner.address, addr1.address, 0);

        expect(await nft.ownerOf(0)).to.equal(addr1.address);
    });

    it('loses nft owner after renouncement', async () => {
        const admin = await accounts[0].getAddress();
        await nft.renounceOwnership({ from: admin });
        const zero_address = '0x0000000000000000000000000000000000000000';

        expect(zero_address).to.equal(await nft.owner());
    });

    it('is address owns NFT?', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 111, 1111);
        await donation.setNftAddress(nft.address);
        await donation.connect(addr1).donatePlease(1,{ value: ethers.utils.parseEther("0.01") });

        expect(await nft.balanceOf(addr1.address)).to.equal(1);
    });

    it('checked ContractBalance', async () => {
        const [owner, addr1, addr2] = await ethers.getSigners();

        await donation.newCampaign('Hmm', 'hmm', 22222, 1000);
        await donation.setNftAddress(nft.address);
        await donation.connect(addr1).donatePlease(1,{ value: 111 });
        await donation.connect(addr2).donatePlease(1,{ value: 111 });
        const balance = await donation.ContractBalance()
        //console.log(balance.toNumber())
        //const provider = waffle.provider;
        //const balance0ETH = await provider.getBalance(donation.address);
        //console.log(balance0ETH.toNumber())

        expect(await balance.toNumber()).to.equal(222);
    });
});