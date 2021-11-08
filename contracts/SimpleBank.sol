/*
 * This exercise has been updated to use Solidity version 0.8.5
 * See the latest Solidity updates at
 * https://solidity.readthedocs.io/en/latest/080-breaking-changes.html
 */
// SPDX-License-Identifier: MIT
pragma solidity >=0.5.16 <0.9.0;

contract SimpleBank {

    /* State variables
     */
    address public owner = msg.sender;
    mapping (address => uint) internal balances ;
    mapping (address => bool) public enrolled;

    /* Events - publicize actions to external listeners
     */
    event LogEnrolled(address accountAddress);
    event LogDepositMade(address accountAddress, uint amount);
    event LogWithdrawal(address accountAddress, uint withdrawAmount, uint newBalance);

    /* Modifiers
     */
    modifier isEnrolled {
      require(enrolled[msg.sender] == true, "Only enrolled accounts can call this function.");
      _;
    }
    modifier notEnrolled {
      require(enrolled[msg.sender] == false, "Only accounts not enrolled can call this function.");
      _;
    }

    /* Functions
     */

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function () external payable {
        revert();
    }

    /// @notice Get balance
    /// @return The balance of the user
    function getBalance() public view returns (uint) {
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public notEnrolled returns (bool){
      // update enrollment status and emit event
      enrolled[msg.sender] = true;
      emit LogEnrolled(msg.sender);

      return enrolled[msg.sender];
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    function deposit() public payable isEnrolled returns (uint) {
      // update balance and emit event
      balances[msg.sender] += msg.value;
      emit LogDepositMade(msg.sender, msg.value);

      return balances[msg.sender];
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    function withdraw(uint withdrawAmount) public isEnrolled returns (uint) {
      // ensure there's enough to withdraw
      require(balances[msg.sender] >= withdrawAmount);

      // send ether & update balances
      msg.sender.transfer(withdrawAmount);
      balances[msg.sender] -= withdrawAmount;

      // emit & return
      emit LogWithdrawal(msg.sender, withdrawAmount, balances[msg.sender]);
      return balances[msg.sender];
    }
}
