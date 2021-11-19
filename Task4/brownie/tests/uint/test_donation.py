from os import name
from brownie.network import chain
import brownie
import pytest
from brownie import accounts, Donation, DonateAndTakeNFT
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
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.createCampaign('Hej', 'hej', 222, 222)
    donation.setNFTAddress('0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6') 
    donation.donate(1, {'from': accounts[2],'value':111})
    donation.donate(2, {'from': accounts[2],'value':111})
    assert donation.campaigns(1)[5] == True
    assert donation.campaigns(2)[5] == False

def test_nft_owner(donation, nft):
    assert donation.owner() == nft.owner()

def test_campaign_balance(donation, accounts):
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    #donation.createCampaign('Hej', 'hej', 222, 222)
    assert donation.campaigns(1)[4] == donation.balance()

def test_setAddress_NFT(donation, accounts):
    donation.setNFTAddress(accounts[4])
    newNFTaddress = donation.contractAddress()
    assert newNFTaddress == accounts[4]


def test_owner_nft(nft):
    owner = nft.owner()
    assert owner == accounts[0]

def test_transferFrom(nft, donation, accounts):
    donation.createCampaign('Hmm', 'hmm', 111, 1111)
    donation.setNFTAddress('0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6') 
    donation.donate(1, {'from': accounts[0],'value':111})
    donation.donate(1, {'from': accounts[0],'value':111})
    nft.transferFrom(accounts[0], accounts[1], 0, {'from': accounts[0]})
    assert nft.ownerOf(0) == accounts[1]

def teste_transferOwnership_nft_req(nft, accounts):
    with brownie.reverts():
        for i in range(2):
            nft.transferOwnership(accounts[i], {'from': accounts[i]})


def teste_cmpaigns_id_counter(donation, accounts):
    donation.createCampaign('Hmm', 'hmm', 111, 111)
    donation.createCampaign('Hej', 'hej', 222, 222)
    counterCampaigns = donation.Index()
    assert counterCampaigns == 2


def test_campaign_creation_req(donation, accounts):
    with brownie.reverts():
        donation.createCampaign('Hmm', 'hmm', 111, 1111,{"from": accounts[1]})




