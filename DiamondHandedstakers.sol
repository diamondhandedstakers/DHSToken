pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed


import "./BEP20.sol";


contract DiamondHandedstakers is BEP20 ('DiamondHandedstakers', 'DHS') {
    
    // Burn address
    address public  burnAddress = 0x000000000000000000000000000000000000dEaD;
    // DEV address
    address public  devAddress;
    // Fee address
    address public  feeAddress;


    // token supply
    uint256 tSuppy = 3000000 * 10**18;
    
    // Contract address excluded from any token Tax.
    address public noTaxAddr = 0x000000000000000000000000000000000000dEaD;
    
    // Transfer Burn Rate: 100 = 1%
    uint16 public  burnFee = 100;    
    // Transfer FEE Rate: 100 = 1%
    uint16 public  teamFee = 100;
    // Divider for Fees
    uint16 public feeDivider = 10000;


    // length of one Claim Period in seconds
    uint256 public periodDuration = 86400; // 86400 = 24h


    // stores the users last Claim Period
    mapping (address => uint256) public claimCount;


    constructor (address owner) public {
        devAddress = owner;
        feeAddress = owner;
        _mint(owner, tSuppy);
    }




    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (recipient == burnAddress || sender == devAddress || recipient == feeAddress || sender == noTaxAddr || recipient == noTaxAddr ) {
            super._transfer(sender, recipient, amount);
        } 
        
        else {
            // burn Amount Calculation
            uint256 burnAmount = amount.mul(burnFee).div(feeDivider);            
            // fee Amount Calculation
            uint256 feeAmount = amount.mul(teamFee).div(feeDivider);            
            // transfer Amount Calculation
            uint256 sendAmount = amount.sub(burnAmount).sub(feeAmount);


            require(amount == sendAmount + burnAmount + feeAmount, "token::transfer: Fee values invalid.");


            super._transfer(sender, burnAddress, burnAmount);
            super._transfer(sender, feeAddress, feeAmount);
            super._transfer(sender, recipient, sendAmount);
        }
    }
    
    // Update "excluded from all fees" Address
    function SetNoTaxAddress(address _noTaxAddress) public onlyOwner {
        noTaxAddr = _noTaxAddress;
    }


    // Update the Dev and Fee Address
    function SetDevAndTaxAddress(address _devAddress, address _feeAddress) public onlyOwner {
        devAddress = _devAddress;
        feeAddress = _feeAddress;
    }


    // Update the Team and Burn Fee
    function setTeamAndBurnFee(uint16 _teamFee, uint16 _burnFee) external onlyOwner() {
        require (_teamFee <= 1000 && _burnFee <= 1000, "setTeamAndBurnFee: 10% is the max limit");
        teamFee = _teamFee;
        burnFee = _burnFee;
    }


    // Set the length of 1 Period in seconds
    function _setPeriodDuration(uint256 _periodDuration) external onlyOwner() {
        require (_periodDuration >= 86400 && _periodDuration <= 2592000, "setPeriodDuration: duration must be between 1 and 30 days!");
        periodDuration = _periodDuration;
    }


    // returns the current Global Claim Counter Value
    function getGolbalClaimCount () public view returns(uint256) {
        return block.timestamp.div(periodDuration);
    }
    
}