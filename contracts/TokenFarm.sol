// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./DAppToken.sol";
import "./LPToken.sol";

contract TokenFarm {
    string public name = "Proportional Token Farm";
    address public owner;
    DAppToken public dappToken;
    LPToken public lpToken;

    uint256 public constant REWARD_PER_BLOCK = 1e18; // 1 token DAPP por bloque
    uint256 public totalStakingBalance;

    address[] public stakers;

    mapping(address => uint256) public stakingBalance;
    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public pendingRewards;
    mapping(address => bool) public hasStaked;
    mapping(address => bool) public isStaking;

    // Eventos
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);
    event RewardsDistributed(uint256 totalReward);

    constructor(DAppToken _dappToken, LPToken _lpToken) {
        dappToken = _dappToken;
        lpToken = _lpToken;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede ejecutar");
        _;
    }

    modifier stakingOnly() {
        require(isStaking[msg.sender], "No estas haciendo staking");
        _;
    }

    // Depositar tokens LP
    function deposit(uint256 _amount) external {
        require(_amount > 0, "Debe depositar al menos 1 token");

        // Calcular recompensas pendientes antes de actualizar balances
        distributeRewards(msg.sender);

        // Transferir LP al contrato
        lpToken.transferFrom(msg.sender, address(this), _amount);

        // Actualizar balances
        stakingBalance[msg.sender] += _amount;
        totalStakingBalance += _amount;

        // Agregar al array de stakers si es nuevo
        if(!hasStaked[msg.sender]) {
            stakers.push(msg.sender);
            hasStaked[msg.sender] = true;
        }

        isStaking[msg.sender] = true;

        // Inicializar checkpoint si es la primera vez
        if(checkpoints[msg.sender] == 0){
            checkpoints[msg.sender] = block.number;
        }

        emit Deposit(msg.sender, _amount);
    }

    // Retirar todos los tokens LP
    function withdraw() external stakingOnly {
        uint256 balance = stakingBalance[msg.sender];
        require(balance > 0, "No hay tokens para retirar");

        // Calcular recompensas antes de restablecer balances
        distributeRewards(msg.sender);

        stakingBalance[msg.sender] = 0;
        totalStakingBalance -= balance;
        isStaking[msg.sender] = false;

        lpToken.transfer(msg.sender, balance);

        emit Withdraw(msg.sender, balance);
    }

    // Reclamar recompensas pendientes
    function claimRewards() external {
        uint256 reward = pendingRewards[msg.sender];
        require(reward > 0, "No hay recompensas pendientes");

        pendingRewards[msg.sender] = 0;

        dappToken.mint(msg.sender, reward);

        emit RewardsClaimed(msg.sender, reward);
    }

    // Distribuir recompensas a todos los usuarios
    function distributeRewardsAll() external onlyOwner {
        uint256 totalDistributed = 0;
        for(uint i = 0; i < stakers.length; i++){
            if(isStaking[stakers[i]]){
                uint256 reward = distributeRewards(stakers[i]);
                totalDistributed += reward;
            }
        }
        emit RewardsDistributed(totalDistributed);
    }

    // Calcular y actualizar recompensas de un usuario
    function distributeRewards(address beneficiary) private returns(uint256) {
        uint256 lastCheckpoint = checkpoints[beneficiary];
        if(lastCheckpoint == 0 || totalStakingBalance == 0) return 0;

        uint256 blocksPassed = block.number - lastCheckpoint;
        uint256 userStake = stakingBalance[beneficiary];
        uint256 reward = (REWARD_PER_BLOCK * blocksPassed * userStake) / totalStakingBalance;

        pendingRewards[beneficiary] += reward;
        checkpoints[beneficiary] = block.number;

        return reward;
    }
}
