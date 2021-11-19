from brownie import Donation, accounts



def deploy():
    donation = Donation.deploy({'from': accounts[0]})
    return donation


def main():
    deploy()
