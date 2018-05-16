pragma solidity ^0.4.19;

import "./SafeMath.sol";

/// @title TokenConfig fot boltt token ERC-20 complience.
/// BOLTT , Incent Loyalty Pty Ltd and Bok Consulting Pty Ltd 2017.
/// @author BolttCoin OU <info@boltt.com>
/// Implements EIP20 token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md


contract TokenConfig {
    
    string public constant SYMBOL = "BOLTT";
    string public constant NAME = "BOLTT COIN";
    uint8 public constant DECIMAL = 8; // 8 decimal same as WAVES
    uint256 _totalSupply = 170*10**6*10**8; // 170 million BOLTT token supply
}

/// @title ERC20Interface for ERC-20 standards.
/// @author Boltt Sports Technology.


contract ERC20Interface {
    
    /// @dev get total token supply.
    function totalSupply() public view returns (uint256 totalSupply);
    
    /// @dev get balance of another address.
    /// @param _owner : address of owner.
    function balanceOf(address _owner) public view returns (uint256 balance);
    
    /// @dev transfer _value amount _from address.
    /// @param _to : address.
    /// @param _value : uint256 of amount.
    function transfer(address _to, uint256 _value) public returns (bool success);
    
    /// @dev send _value amount token from _from to _to.
    /// @param _from : from address.
    /// @param _to : to address.
    /// @param _value : amount of token.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    
    /// @dev _spender to withdraw from your account, multiple times, up to the _value amount.
    /// @param _spender : address of the approved address.
    /// @param _value : uint256 of amount.
    function approve(address _spender, uint256 _value) public returns (bool success);
    
    /// @dev Returns the amount which _spender is still allowed to withdraw from _owner
    /// param _spender : address of the spender.
    /// @param _owner : address of the token owner.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    
    /// @dev event to trigger when a transfer is approved
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /// @dev Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/// @title BolttToken
/// @author Bollt sports technology.
/// @notice implementation of ERC-20 standards.


contract BolttToken is ERC20Interface, TokenConfig {
    
    /*** LIBRARIES ***/
    /// SafeMath for secure calculation purpose.
    using SafeMath for uint256;
    
    /*** PUBLIC STATE VARIABLES ***/
    //owner of the contract.
    address public bolttReserve;
    
    //rate per ether.
    uint256 public rate = 40;// 4000 BOLTT per ether
    
    //crowdsale status.
    bool public paused = false;
    
    bool public running = true;
    
    uint256 public lockPeriod = now + 90 days;
    
    // crowdsale stages.
    uint256 public stageNumber = 0;
    
    // balance of each account.
    mapping (address => uint256) public balances;
    
    // owner of an account approves the transfer of amount to other account.
    mapping (address => mapping (address => uint256)) public allowed;
    
    // white list
    mapping (address => bool) public whiteList;
    
    /*** MODIFIERS ***/
    
    /// @dev for only owner.
    modifier onlyOwner() {
        
        require(msg.sender == bolttReserve);
        _;
    }
    
    modifier isPaused {
        
        require(!paused);
        _;
    }
    
    modifier canBuy {
        
        require(running);
        require(!paused);
        _;
    }

    /*** CONSTRUCTER ***/
    
    function BolttToken(address _address) public {
        
        bolttReserve = _address;
        balances[bolttReserve] = _totalSupply;
    }
    
    
    /// @dev fallback function.
    
    function () public payable {
        
        buy();
    }
    
    /*** PUBLIC FUNCTIONS ***/
    
    /// @dev get total supply.
    function totalSupply() public view returns(uint256 totalSupply) {
        
        totalSupply = _totalSupply;
    }
    
    /// @dev get balance of an address.
    /// @param _owner address : address of the owner.
    function balanceOf( address _owner) public view returns (uint256 balance) {
        
        return balances[_owner];
    } 
    
    /// @dev change the allocation rate per ether.
    function rateAllocation(uint256 _rate) public onlyOwner {
        
        rate = _rate;
        emit rateAllocationEvent(rate);
    }
    
    ///@dev halt the sale.
    function stopSale() public onlyOwner {
        
        running = false;
    }
    
    
    /// @dev transfer _amount amount to _to address.
    /// @param _to address : address to.
    /// @param _amount : uint256 of token.
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        
        require(now >= lockPeriod || msg.sender == bolttReserve);
        if (balances[msg.sender] >= _amount && _amount > 0 && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    /// @dev sent _amount of token from _from to _to.
    /// @param _from : address.
    /// @param _to : address.
    /// @param _amount : uint256.
    /// @notice : The transferFrom method is used for a withdraw workflow, allowing contracts to send
    /// tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    /// fees in sub-currencies; the command should fail unless the _from account has
    /// deliberately authorized the sender of the message via some mechanism; we propose
    /// these standardized APIs for approval:
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool success) {
        
        require(now >= lockPeriod || msg.sender == bolttReserve);
        if (balances[_from] >= _amount &&
            allowed[_from][msg.sender] >= _amount &&
            _amount > 0 &&
            balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            emit Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    /// @dev : Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    /// @param _spender : address.
    /// @param _amount : uint256.
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    event WavesTransfer(address indexed _from, string wavesAddress, uint256 amount);
    event rateAllocationEvent(uint256 amount);
    event lockPeriodUpdate(uint256 period);
    
    /// @dev move tokens from ethereum to waves.
    /// @param waveAddress : waves wallet address.
    /// @param _amount : amount to be transfer.
    function moveToWaves(string waveAddress, uint256 _amount) public returns (address senderAdd, string waveAdd, uint256 amountSent) {
        
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[bolttReserve] + _amount > balances[bolttReserve]) {
                
            balances[msg.sender] -= _amount;
            balances[bolttReserve] += _amount;
            emit Transfer(msg.sender, bolttReserve, _amount);
            senderAdd = msg.sender;
            waveAdd = waveAddress;
            amountSent = _amount;
            return (senderAdd, waveAdd, amountSent);
            } else {
                
            return (msg.sender, "null", 0);
        }

    }
    
    
    /// @dev buy tokens.
    function buy() public canBuy payable  {
        
        // Minimum required transaction amount should be greater than 0.001 ETH.
        require(msg.value > 10**16);
        
        uint256 ethervalue = msg.value * 100;
        uint256 mintedToken = (((ethervalue / 10**16) * rate) / 100) * 10**8;
        
        /*
        Contributions between 0.1-100 ETH will receive a 20% Bonus, 
        Contributions between 100-500 ETH will receive a 30% Bonus, 
        Contributions between 500-1500 ETH will receive 40% Bonus & 
        Contributions above 1500 ETH will receive a 50% Bonus. 
        During private sales, white-listed members will recieve an additional 5% bonus.
        */
        if (whiteList[msg.sender] == true && stageNumber == 0) {
            // For white listed users extra bonus of 5%.
            
            if (msg.value >= 0 ether && msg.value < 100 ether){
                //  Contributions between 0.1-100 ETH will receive a 25% Bonus.
                mintedToken = mintedToken + mintedToken * 25 / 100;
            } else if (msg.value >= 100 ether && msg.value < 500 ether) {
                // Contributions between 100-500 ETH will receive a 35% Bonus.
                mintedToken = mintedToken + mintedToken * 35 / 100;
            } else if ( msg.value >= 500 ether && msg.value < 1500 ether) {
                // Contributions between 500-1500 ETH will receive a 45% Bonus.
                mintedToken = mintedToken + mintedToken * 45 / 100;
            } else if (msg.value >= 1500 ether) {
                // Contributions above 1500 ETH will receive a 55% Bonus.
                mintedToken = mintedToken + mintedToken * 55 / 100;
            }
            
        } else {
            // For non-whitelisted users bonus slabs as follows.
            if (stageNumber == 0) {
                
                if (msg.value >= 0 ether && msg.value < 100 ether){
                    // Contributions between 0.1-100 ETH will receive a 20% Bonus. 
                    mintedToken = mintedToken + mintedToken * 20 / 100;
                } else if(msg.value >= 100 ether && msg.value < 500 ether) {
                    // Contributions between 100-500 ETH will receive a 30% Bonus. 
                    mintedToken = mintedToken + mintedToken * 30 / 100;
                } else if ( msg.value >= 500 ether && msg.value < 1500 ether) {
                    // Contributions between 500-1500 ETH will receive 40% Bonus.
                    mintedToken = mintedToken + mintedToken * 40 / 100;
                } else if (msg.value >= 1500 ether) {
                    // Contributions above 1500 ETH will receive a 50% Bonus.
                    mintedToken = mintedToken + mintedToken * 50 / 100;
                }
                
                
            } else if (stageNumber == 1) {
                
                if(msg.value >= 0 ether && msg.value < 100 ether){
                    // Contributions between 0.1-100 ETH will receive a 10% Bonus. 
                    mintedToken = mintedToken + mintedToken * 10 / 100;
                } else if(msg.value >= 100 ether && msg.value < 500 ether) {
                    // Contributions between 100-500 ETH will receive a 15% Bonus. 
                    mintedToken = mintedToken + mintedToken * 15 / 100;
                } else if ( msg.value >= 500 ether && msg.value < 1500 ether) {
                    // Contributions between 500-1500 ETH will receive a 20% Bonus. 
                    mintedToken = mintedToken + mintedToken * 20 / 100;
                } else if (msg.value >= 1500 ether) {
                    // Contributions above 1500 ETH will receive a 25% Bonus. 
                    mintedToken = mintedToken + mintedToken * 25 / 100;
                }
                
            } 
        }
        
        require(balances[bolttReserve] > mintedToken);
        balances[msg.sender] += mintedToken;
        balances[bolttReserve] -= mintedToken;
    }
    
    
    function payout() public onlyOwner {
        
        address _contract = address(this);
        bolttReserve.transfer(_contract.balance);
    }
    
    
    /*** PUBLIC FUNCTIONS ***/
    
    /// @notice pause the crowdsale in emergency.
    function pauseSale() public onlyOwner {
        
        paused = true;
    }
    
    /// @notice unpause the sale.
    function resumeSale() public onlyOwner {
        
        paused = false;
    }
    
    /// @dev change the owner of the contract.
    function changeOwner(address _newOwner) public onlyOwner {
        
        bolttReserve = _newOwner;
    }
    
    /// @dev lockPeriod.
    function setLockPeriod(uint256 _newLockPeriod) public onlyOwner {
        
        lockPeriod = now + _newLockPeriod * 1 days;
        emit lockPeriodUpdate(_newLockPeriod);
    }
    
    /// @dev stages configuration.
    function status() public view returns(uint256) {
        
        return stageNumber;
    }
    
    /// @dev changing the stage name.
    function activatePreSale() public onlyOwner {
        
        stageNumber = 1;
    }
    
    function activatePublicSale() public onlyOwner {
        
        stageNumber = 2;
    }
    
    /// @notice whitelist address.
    function whiteListAddress(address _address) public onlyOwner {
        
        whiteList[_address] = true;
    }
    
    function isWhiteList(address _address) public view returns (bool) {
        return whiteList[_address];
    }
}
