from os import name
from brownie.network import chain
import brownie
import pytest
from brownie import accounts, Donation
from brownie import DonateAndTakeNFT
#from scripts.deploy import deploy


@pytest.fixture
def donation():
    return accounts[0].deploy(Donation)


@pytest.fixture
def nft():
    return accounts[0].deploy(DonateAndTakeNFT)

def test_owner(donation):
    owner = donation.owner()
    assert owner == accounts[0]

def test_transferOwner(donation,accounts):
    donation.transferOwnership(accounts[1])
    assert donation.owner() == accounts[1]

def test_is_campaigns_completed(donation, accounts):
    Address = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.createCampaign('Hej', 'hej', 222, 222)
    donation.setNFTAddress(Address) 
    donation.donate(1, {'from': accounts[2],'value':111})
    donation.donate(2, {'from': accounts[2],'value':111})
    assert donation.campaigns(1)[5] == True
    assert donation.campaigns(2)[5] == False

def test_nft_owner(donation, nft):
    assert donation.owner() == nft.owner()

def test_campaign_balance(donation):
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    #donation.createCampaign('Hej', 'hej', 222, 222)
    assert donation.campaigns(1)[4] == donation.balance()

def test_setAddress_NFT(donation):
    donation.setNFTAddress(accounts[4])
    newNFTaddress = donation.contractAddress()
    assert newNFTaddress == accounts[4]

def test_owner_nft(nft):
    owner = nft.owner()
    assert owner == accounts[0]

def test_transferFrom(nft, donation, accounts):
    donation.createCampaign('Hmm', 'hmm', 111, 1111)
    addr = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
    donation.setNFTAddress(addr) 
    donation.donate(1, {'from': accounts[0],'value':11})
    donation.donate(1, {'from': accounts[1],'value':11})
    nft.transferFrom(accounts[0], accounts[1], 0, {'from': accounts[0]})
    assert nft.ownerOf(0) == accounts[1]


def test_transferOwnership_nft_req(nft, accounts):
    with brownie.reverts():
        for i in range(2):
            nft.transferOwnership(accounts[i], {'from': accounts[i]})

def test_campaigns_id_counter(donation, accounts):
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.createCampaign('Hej', 'hej', 222, 222)
    counterCampaigns = donation.Index()
    assert counterCampaigns == 2


def test_only_admin_can_create_campaings(donation, accounts):
    with brownie.reverts():
        donation.createCampaign('Hmm', 'hmm', 111, 111, {'from': accounts[1]})

def test_isGoalAchived(donation, accounts):
    addr = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.setNFTAddress(addr) 
    donation.donate(1, {'from': accounts[0],'value':111})

    with brownie.reverts():
        donation.donate(1, {'from': accounts[1],'value':111})


def test_if_address_donated_some_amount(donation, accounts):
    addr = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.setNFTAddress(addr)
    donation.donate(1, {'from': accounts[0],'value':111})
    Donated1 = donation.ownerDonated(accounts[0])
    Donated2 = donation.ownerDonated(accounts[1])

    assert Donated1 == True
    assert Donated2 == False

def test_loses_owner_after_renouncement(donation, accounts):
    admin = accounts[0]
    zero_address = '0x0000000000000000000000000000000000000000'
    donation.renounceOwnership({ 'from': admin })

    assert zero_address == donation.owner()

def test_loses_nft_owner_after_renouncement(nft, accounts):
    admin = accounts[0]
    zero_address = '0x0000000000000000000000000000000000000000'
    nft.renounceOwnership({ 'from': admin })

    assert zero_address == nft.owner()

def test_is_address_owns_NFT(donation, accounts, nft):
    addr = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'                  #kako da dodjem do ove adrese ? kako da je pozovem iz drugog ugovora 
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.setNFTAddress(addr)
    donation.donate(1, {'from': accounts[0],'value':111})
    assert nft.balanceOf(accounts[0]) == 1

def test_ownerOf(donation, accounts, nft):
    address = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
    donation.createCampaign('Hmm', 'hmm', 111, 1111)
    donation.setNFTAddress(address)
    donation.donate(1, {'from': accounts[0],'value':11})
    donation.donate(1, {'from': accounts[1],'value':11})
    assert nft.ownerOf(0) == accounts[0]

def test_deadline(donation, accounts):
    timeStamp_111days = 1645009200
    donation.createCampaign('Hmm', 'hmm', 1645009200, 1111)
    currently_timeStamp = chain.time()
    future_timestamp = 1647450856
    assert donation.campaigns(1)[2] > currently_timeStamp


