from brownie import Donation, accounts, NFT


def deploy():
    donation = Donation.deploy({'from': accounts[0]})
    nft = NFT.deploy({'from': accounts[0]})
    return donation
    return nft

def main():
    deploy()
