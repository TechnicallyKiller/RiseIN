// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    address owner;
    constructor(){
        owner=msg.sender;
        voted_addresses.push(msg.sender);

    }
uint256 private counter; 
    struct Proposal {
        string title;
        string description; // Description of the proposal
        uint256 approve; // Number of approve votes
        uint256 reject; // Number of reject votes
        uint256 pass; // Number of pass votes
        uint256 total_vote_to_end; // When the total votes in the proposal reaches this limit, proposal ends
        bool current_state; // This shows the current state of the proposal, meaning whether if passes of fails
        bool is_active; // This shows if others can vote to our contract
    }
    modifier onlyOwner1(){
        require(owner==msg.sender,"failed");
        _;
    }
function isVoted(address _address) public view returns (bool) {
    for (uint i = 0; i < voted_addresses.length; i++) {
        if (voted_addresses[i] == _address) {
            return true;
        }
    }
    return false;
}
function setOwner(address new_owner) external onlyOwner1 {
    owner = new_owner;
}

    mapping(uint256 => Proposal) proposal_history; // Recordings of previous proposals
    function create(string calldata _title , string calldata _description, uint256 _total_vote_to_end) external onlyOwner1 {
        counter += 1;
        proposal_history[counter] = Proposal(_title, _description, 0, 0, 0, _total_vote_to_end, false, true);
}
modifier active() {
    require(proposal_history[counter].is_active == true, "The proposal is not active");
    _;
}


address[]  private voted_addresses;
function vote(uint8 choice) external newVoter(msg.sender) {
    Proposal storage prop1= proposal_history[counter];
    uint256 total_votes= prop1.approve+prop1.reject+prop1.pass;
    voted_addresses.push(msg.sender);
    if(choice==1){
        prop1.approve+=1;
        prop1.current_state=calculateCurrentState();
    }
    else if(choice==2){
        prop1.reject+=1;
        prop1.current_state=calculateCurrentState();
        
    }
    else if(choice==0){
        prop1.pass+=1;
        prop1.current_state=calculateCurrentState();
    }
    if ((prop1.total_vote_to_end - total_votes == 1) && (choice == 1 || choice == 2 || choice == 0)) {
    prop1.is_active = false;
    voted_addresses=[owner];

}

}

modifier newVoter(address _address) {
    require(!isVoted(_address), "Address has already voted");
    _;
}

function calculateCurrentState() private view returns (bool){
Proposal storage proposal = proposal_history[counter];
uint256 approve= proposal.approve;
uint256 reject = proposal.reject;
uint256 pass =proposal.pass;
uint256 total=approve+reject+pass;

if(pass%2!=0){
    pass+=1;
    pass=pass/2;

}
if(total==0){
    return false;
}

if(approve>reject+pass){
    return true;
}
else if(approve==reject+pass && total>0) {
    return true;
}
else{
    return false;
}
}
function teminateProposal() external onlyOwner1 active {
    proposal_history[counter].is_active = false;
}
function getCurrentProposal() external view returns(Proposal memory) {
    return proposal_history[counter];
}

}