// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
  Simple PHX token (no DEX stuff):
  - ERC-20 pieces (events + allowance) so wallets work
  - 1% fee on non-owner transfers -> goes to owner
  - pause flag, cooldown, anti-whale
  - mint / burn / airdrop / kill (owner only)
*/

contract Coin {
    // token meta
    string public name = "Phoenix";
    string public symbol = "PHX";
    uint8  public decimals = 18;

    // supply + balances + allowances
    uint256 public totalSupply = 630_000 * 10**18;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // standard ERC-20 events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // owner + pause
    address public owner;
    uint8   public flag = 0; // 0 = ok, 1 = paused
    modifier onlyOwner() { require(msg.sender == owner, "owner only"); _; }

    // cooldown + anti-whale
    mapping(address => uint256) public lastTransferTime;
    uint256 public cooldownTime = 10;                   // seconds between sends (non-owner)
    uint256 public maxTx       = 50_000 * 10**18;       // per-tx cap
    uint256 public maxWallet   = (35 * 630_000 * 10**18) / 100; // 35% of initial supply

    // fee (1% by default) -> goes to owner
    uint256 public feeBps = 100; // basis points (100 = 1%)

    constructor() {
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }

    // admin knobs
    function pause() external onlyOwner { flag = 1; }
    function unpause() external onlyOwner { flag = 0; }
    function setCooldown(uint256 s) external onlyOwner { cooldownTime = s; }
    function setMaxTx(uint256 m) external onlyOwner { maxTx = m; }
    function setMaxWallet(uint256 m) external onlyOwner { maxWallet = m; }
    function setFeeBps(uint256 bps) external onlyOwner { require(bps <= 500, "max 5%"); feeBps = bps; }

    // ERC-20 approve / transfer / transferFrom
    function approve(address spender, uint256 value) external returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        uint256 a = allowance[from][msg.sender];
        require(a >= value, "allowance");
        if (a != type(uint256).max) allowance[from][msg.sender] = a - value;
        _transfer(from, to, value);
        return true;
    }

    // core move logic (all checks + fee live here)
    function _transfer(address from, address to, uint256 value) internal {
        require(flag == 0, "paused");
        require(to != address(0), "bad to");
        require(value > 0, "zero");

        // cooldown (non-owner)
        if (from != owner) {
            require(block.timestamp >= lastTransferTime[from] + cooldownTime, "cooldown");
            lastTransferTime[from] = block.timestamp;
        }

        // anti-whale
        require(value <= maxTx, "maxTx");
        if (to != owner) {
            require(balanceOf[to] + value <= maxWallet, "maxWallet");
        }

        // fee (skip if owner involved)
        uint256 fee = 0;
        if (from != owner && to != owner && feeBps > 0) {
            fee = (value * feeBps) / 10_000;
        }

        // moves (solidity 0.8 reverts on under/overflow)
        balanceOf[from] -= value;
        if (fee > 0) {
            balanceOf[owner] += fee;             // fee goes to owner (simple)
            emit Transfer(from, owner, fee);
            value -= fee;
        }
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    // mint / burn / airdrop / kill
    function mint(uint256 amount) external onlyOwner returns (bool) {
        totalSupply += amount;
        balanceOf[owner] += amount;
        emit Transfer(address(0), owner, amount);
        return true;
    }

    function burn(uint256 amount) external onlyOwner returns (bool) {
        balanceOf[owner] -= amount;
        totalSupply -= amount;
        emit Transfer(owner, address(0), amount);
        return true;
    }

    function airdrop(address[] memory recips, uint256 amount) external onlyOwner returns (bool) {
        for (uint i = 0; i < recips.length; i++) {
            totalSupply += amount;
            balanceOf[recips[i]] += amount;
            emit Transfer(address(0), recips[i], amount);
        }
        return true;
    }

    function emergencyKill() external onlyOwner {
        selfdestruct(payable(owner)); // learning only; discouraged in real deployments
    }
}
