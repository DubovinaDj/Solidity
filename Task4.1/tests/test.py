from os import name
from brownie.network import chain
import brownie
import pytest
from brownie import ZERO_ADDRESS, accounts, Donation, NFT
#from scripts.deploy import deploy


@pytest.fixture
def donation():
    return accounts[0].deploy(Donation)

@pytest.fixture
def nft():
    return accounts[0].deploy(NFT)

address1 = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'
name1, name2  = 'Hmm', 'Hej'
desc1, desc2= 'hmm', 'hej'
goal1, goal2 = 111, 222
deadline1, deadline2 = 999, 1000



def test_owner(donation):
    owner = donation.owner()
    assert owner == accounts[0]

def test_transferOwner(donation,accounts):
    donation.transferOwnership(accounts[1])
    assert donation.owner() == accounts[1]

def test_is_campaigns_completed(donation, accounts):
    donation.newCampaign(name1, desc1, deadline1, goal1)
    donation.newCampaign(name2, desc2, deadline2, goal1)
    donation.setNftAddress(address1) 
    donation.donatePlease(1, {'from': accounts[2],'value':100})
    donation.donatePlease(2, {'from': accounts[2],'value':180})
    assert donation.campaigns(1)[5] == False
    assert donation.campaigns(2)[5] == True

def test_nft_owner(donation, nft):
    assert donation.owner() == nft.owner()

def test_campaign_balance(donation, accounts):
    donation.newCampaign(name1, desc1, deadline1, goal1)
    #donation.createCampaign('Hej', 'hej', 222, 222)
    assert donation.campaigns(1)[4] == donation.balance()

def test_setAddress_NFT(donation, accounts):
    donation.setNftAddress(accounts[4])
    addressNFT = donation.checkNftAddress()
    assert addressNFT == accounts[4]


def test_owner_nft(nft):
    owner = nft.owner()
    assert owner == accounts[0]

def test_transferFrom(nft, accounts):
    nft.mint(accounts[0])
    nft.transferFrom(accounts[0], accounts[1], 0, {'from': accounts[0]})
    assert nft.ownerOf(0) == accounts[1]

def teste_transferOwnership_nft_req(nft, accounts):
    with brownie.reverts():
        for i in range(2):
            nft.transferOwnership(accounts[i], {'from': accounts[i]})


def teste_campaigns_id_counter(donation, accounts):
    donation.newCampaign(name1, desc1, deadline1, goal1)
    donation.newCampaign(name2, desc2, deadline2, goal2)
    counterCampaigns = donation.campaignID()
    assert counterCampaigns == 2


def test_only_admin_can_create_campaigns(donation, accounts):
    with brownie.reverts():
        donation.newCampaign(name1, desc1, deadline1, goal1,{"from": accounts[1]})

def test_init_ERC721(nft):
    assert nft.name() == 'Gift NTF'
    assert nft.symbol() == 'DNTF'

def test_contract_balance(donation, accounts):
    donation.setNftAddress(address1)
    donation.newCampaign(name1, desc1, deadline1, goal1)
    donation.donatePlease(1, {'from': accounts[1], 'value': goal1 + 10})
    assert donation.ContractBalance() == goal1

def test_Is_address_ownerOf_nft(donation, accounts,nft):
    donation.setNftAddress(address1)
    donation.newCampaign(name2, desc2, deadline2, goal2)
    donation.donatePlease(1, {'from': accounts[0], 'value': 10 })
    nft.mint(accounts[0])
    expect = 1
    assert nft.ownerOf(0) == accounts[0]
    assert nft.balanceOf(accounts[0]) == expect
    
def test_loses_nft_owner_after_renouncement(nft, accounts):
    admin = accounts[0]
    nft.renounceOwnership({'from': admin})
    assert ZERO_ADDRESS == nft.owner()

def test_deadline(donation):
    deadline = 1645009200
    currently_timeStamp = chain.time()
    donation.newCampaign(name2, desc2, chain.sleep(99999), goal2)
    assert donation.campaigns(1)[3] > currently_timeStamp





