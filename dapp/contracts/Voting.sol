pragma solidity ^0.8.0 <0.8.19;

contract Voting {
    address private admin;
    mapping(address => Voter) private voters;
    uint private voterCount;
    WorkflowStatus public status;
    //Il y a possibilité d'avoir un ou plusieurs gagnants selon l'instance
    uint public numberOfWinningProposals = 1;
    uint[] public winningProposalIds;
    Proposal[] private proposals;

    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }

    constructor(uint _numberOfWinningProposals) {
        numberOfWinningProposals = _numberOfWinningProposals;
        status = WorkflowStatus.RegisteringVoters;
        admin = msg.sender;
        voterCount = 0;
    }

    event VoterRegistered(address voterAddress);

    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    event ProposalRegistered(uint proposalId);

    event Voted(address voter, uint proposalId);

    modifier checkStage(WorkflowStatus _status) {
        require(status == _status, "Le statut est invalide");
        _;
    }

    modifier checkAdmin() {
        require(msg.sender == admin, unicode"Vous n'êtes pas l'administrateur");
        _;
    }

    function getVoterCount() public view returns (uint) {
        return voterCount;
    }

    function getVoters() public view returns (address[] memory){
        address[] memory registeredVotersArray = new address[](voterCount);

        uint currentIndex = 0;
        for (uint i = 0; i < registeredVotersArray.length; i++) {
            address voterAddress = registeredVotersArray[i];
            if (voters[voterAddress].isRegistered) {
                registeredVotersArray[currentIndex] = voterAddress;
                currentIndex++;
            }
        }

        return registeredVotersArray;
    }

    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }

    function getProposals() public view returns (Proposal[] memory){
        return proposals;
    }

    function getAdmin() public view returns (address){
        return admin;
    }

    function registerVoter(address _voterAddress) public checkAdmin checkStage(WorkflowStatus.RegisteringVoters) {
        voters[_voterAddress] = Voter(true, false, 0);
        voterCount++;


        emit VoterRegistered(_voterAddress);
    }

    function startProposalsRegistration() public checkAdmin checkStage(WorkflowStatus.RegisteringVoters) {
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, WorkflowStatus.ProposalsRegistrationStarted);
    }

    function registerProposal(string memory _description) public checkStage(WorkflowStatus.ProposalsRegistrationStarted) {
        require(msg.sender == admin || voters[msg.sender].isRegistered, unicode"Vous n'êtes pas enregistré");

        uint proposalId = proposals.length;
        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(proposalId);
    }

    function removeVoter(address _address) public checkAdmin {
        require(status == WorkflowStatus.RegisteringVoters, "Le statut est invalide");
        require(voters[_address].isRegistered, unicode"L'électeur n'est pas enregistré");

        voters[_address].isRegistered = false;
        voterCount--;
    }

    function removeProposal(uint _proposalId) public checkAdmin {
        require(status == WorkflowStatus.ProposalsRegistrationStarted, "Le statut est invalide");
        require(_proposalId < proposals.length, "L'ID est invalide");

        for (uint i = _proposalId; i < proposals.length - 1; i++) {
            proposals[i] = proposals[i + 1];
        }
        proposals.pop();
    }

    function endProposalsRegistration() public checkAdmin checkStage(WorkflowStatus.ProposalsRegistrationStarted) {
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, WorkflowStatus.ProposalsRegistrationEnded);
    }

    function startVotingSession() public checkAdmin checkStage(WorkflowStatus.ProposalsRegistrationEnded) {
        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded, WorkflowStatus.VotingSessionStarted);
    }

    function vote(uint _proposalId) public checkStage(WorkflowStatus.VotingSessionStarted) {
        require(voters[msg.sender].isRegistered, unicode"Vous n'êtes pas enregistré");
        require(!voters[msg.sender].hasVoted, unicode"Vous avez déjà voté");
        require(_proposalId < proposals.length, "ID invalide");

        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender, _proposalId);
    }

    function endVotingSession() public checkAdmin checkStage(WorkflowStatus.VotingSessionStarted) {
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, WorkflowStatus.VotingSessionEnded);
    }

    function countVotes() public checkAdmin checkStage(WorkflowStatus.VotingSessionEnded) {
        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, WorkflowStatus.VotesTallied);

        uint[] memory topProposalIds = new uint[](numberOfWinningProposals);

        for (uint j = 0; j < numberOfWinningProposals; j++) {
            uint maxVoteCount = 0;
            uint winningProposalId = 0;
            for (uint i = 0; i < proposals.length; i++) {
                if (proposals[i].voteCount > maxVoteCount) {
                    maxVoteCount = proposals[i].voteCount;
                    winningProposalId = i;
                }
            }
            topProposalIds[j] = winningProposalId;
            //pour éviter de resélectionner cette proposition, on mets son compte à 0
            proposals[winningProposalId].voteCount = 0;
        }
        winningProposalIds = topProposalIds;
    }

    function getWinner() public view returns (uint[] memory){
        require(status == WorkflowStatus.VotesTallied, unicode"Les votes n'ont pas été comptés");
        return winningProposalIds;
    }
}