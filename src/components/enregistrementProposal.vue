<template>
    <div>
        <h2>Enregistrement des Propositions</h2>
        <div>
            <label for="proposalInput">Nouvelle Proposition :</label>
            <input type="text" id="proposalInput" v-model="newProposal" />
            <button @click="registerProposal">Enregistrer Proposition</button>
        </div>

        <h2>Liste des Propositions Enregistrées</h2>
        <ul>
            <li v-for="(proposal, index) in proposalsList" :key="index">
                {{ proposal }}
            </li>
        </ul>
    </div>
</template>

<script>
import Web3 from "web3";
const web3 = new Web3("http://127.0.0.1:7545");
import votingContract from "/dapp/build/contracts/Voting.json";
import { ref } from "vue";
export default {
    setup() {
        let newProposal = ref("");
        let proposalsList = ref([]);
        let contractInstance = new web3.eth.Contract(
            votingContract.abi,
            "0x99d1AA69dF4Cf58ac4b367f8F5fea08303C73931"
        );
        //remplacer l'adresse par celle qui s'affiche au déploiement du contrat

        async function loadProposals() {
            const proposalCount = contractInstance.methods.getProposalCount().call();
            console.log(proposalCount);
            for (let i = 0; i < proposalCount; i++) {
                const proposal = await contractInstance.methods.getProposals().call();
                console.log("proposals", proposal)
                proposalsList.value.push(proposal[i]);
            }
            console.log(proposalsList.value);
        }

        async function registerProposal() {
            console.log("register");

            const accounts = await web3.eth.getAccounts();
            const sender = accounts[0];
            console.log("SENDER", sender);
            contractInstance.methods
                .startProposalsRegistration()
                .send({ from: sender });

            console.log("proposal", newProposal);
            contractInstance.methods
                .registerProposal(newProposal.value)
                .send({ from: sender });

            await loadProposals();
        }

        return {
            newProposal,
            proposalsList,
            registerProposal,
        };
    },
};
</script>
