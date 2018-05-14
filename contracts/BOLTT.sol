pragma solidity ^0.4.19;

/// @title TokenConfig fot boltt token ERC-20 cmplience.
/// @author Boltt Sports Technology.

contract TokenConfig {
    string public constant symbol = "BOLTT";
    string public constant name = "BOLTT COIN";
    uint8 public constant decimal = 8; // 8 decimal same as WAVES
    uint256 _totalSupply = 170*10**6*10**8; // 170 million BOLTT token supply
}

/// @title ERC20Interface for ERC-20 standards.
/// @author Boltt Sports Technology.

contract ERC20Interface {
    
    /// @dev get total token supply.
    function totalSupply() public constant returns (uint256 totalSupply);
    
    /// @dev get balance of another address.
    /// @param _owner : address of owner.
    function balanceOf(address _owner) public constant returns (uint256 balance);
    
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
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);
    
    /// @dev event to trigger when a transfer is approved
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    /// @dev Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

import './SafeMath.sol';
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
    string public stageName = 'private-sale';
    uint256 public stageNumber = 0;
    
    // balance of each account.
    mapping (address => uint256) public balances;
    
    // owner of an account approves the transfer of amount to other account.
    mapping (address => mapping (address => uint256)) public allowed;
    
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
    
    
    /*** CONSTRUCTER ***/
    
    function BolttToken() public {
        bolttReserve = msg.sender;
        balances[bolttReserve] = _totalSupply;
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
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
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
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
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
    function buy() public payable {
        require(running);
        require(!paused);
        require(msg.value > 10**16);
        // need to decide the rate
        
        uint256 ethervalue = msg.value * 100;
        uint256 mintedToken = (((ethervalue / 10**16) * rate) / 100) * 10**8;
        
        if(stageNumber == 0) {
            
            // minimum investnent for private sale should be 100 ethers.
            require(msg.value >= 100 ether);
            
            if(msg.value >= 100 ether && msg.value < 500 ether) {
                // bonus between 100 and 500 ether is 30%.
                mintedToken = mintedToken + mintedToken * 3 / 10;
            } else if ( msg.value >= 500 ether && msg.value < 1500 ether) {
                // bonus between 500 to 1500 is 40%.
                mintedToken = mintedToken + mintedToken * 2 / 5;
            } else if (msg.value >= 1500 ether) {
                // bonus above 1500 ether is 50%.
                mintedToken = mintedToken + mintedToken / 2;
            }
            
            require(balances[bolttReserve] > mintedToken);
            balances[msg.sender] += mintedToken;
            balances[bolttReserve] -= mintedToken;
            
        } else if (stageNumber == 1) {
            // minimum investnent for pre sale should be 10 ethers.
            require(msg.value > 10 ether);
            
            mintedToken = mintedToken + mintedToken / 5;
            
            require(balances[bolttReserve] > mintedToken);
            balances[msg.sender] += mintedToken;
            balances[bolttReserve] -= mintedToken;
        } else if (stageNumber == 2) {
            
            // no bonus for public stage.
            require(balances[bolttReserve] > mintedToken);
            balances[msg.sender] += mintedToken;
            balances[bolttReserve] -= mintedToken;
        }
        
        
    }
    
    
    /// @dev fallback function.
    
    function () public payable {
        buy();
    }
    
    function payout() public onlyOwner {
        address _contract = address(this);
        bolttReserve.transfer(_contract.balance);
    }
    
    
    /*** PUBLIC FUNCTIONS ***/
    
    /// @notice pause the crowdsale in emergency.
    function paused() public onlyOwner {
        paused = true;
    }
    
    /// @notice unpause the sale.
    function unPaused() public onlyOwner {
        paused = false;
    }
    
    /// @dev change the owner of the contract.
    function changeOwner(address _newOwner) public onlyOwner {
        bolttReserve = _newOwner;
    }
    
    /// @dev lockPeriod.
    function setLockPeriod(uint256 _newLockPeriod) public onlyOwner {
        lockPeriod = now + _newLockPeriod * 1 days;
    }
    
    /// @dev stages configuration.
    function status() public onlyOwner view returns(string) {
        return stageName;
    }
    
    /// @dev changing the stage name.
    function activatePrivateSale() public onlyOwner {
        stageName = 'pre-sale';
        stageNumber = 1;
    }
    
    function activatePublicSale() public {
        stageName = 'public-sale';
        stageNumber = 2;
    }
}
