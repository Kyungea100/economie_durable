<template>
  <div>
    <h2>Enregistrement des Electeurs</h2>
    <div>
      <label for="voterInput">Adresse du nouvel électeur :</label>
      <input type="text" id="voterInput" v-model="newVoter" />
      <button @click="registerVoter">Enregistrer Proposition</button>
    </div>

    <h2>Liste des Propositions Enregistrées</h2>
    <ul>
      voters =
      {{
        votersList
      }}
      <li v-for="(voter, index) in votersList" :key="index">
        {{ voter }}
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
    let newVoter = ref("");
    let votersList = ref([]);
    let contractInstance = new web3.eth.Contract(
      votingContract.abi,
      "0xe8F47f5939cF3C66e730c9311c15DBD7f0273F31"
    );
    //remplacer l'adresse par celle qui s'affiche au déploiement du contrat

    async function loadVoters() {
      const voterCount = contractInstance.methods.getVoterCount().call();
      console.log(voterCount);
      for (let i = 0; i < voterCount; i++) {
        const voter = await contractInstance.methods.getVoters().call();
        votersList.value.push(voter[i]);
      }
      console.log(votersList.value);
    }

    async function registerVoter() {
      console.log("register");
      const accounts = await web3.eth.getAccounts();
      const sender = accounts[0];
      console.log("SENDER", sender);
      const voterCount = contractInstance.methods.getVoterCount().call();
      console.log("Count after registration", voterCount);
      console.log("NEW VOTER", newVoter.value);
      contractInstance.methods.registerVoter(newVoter.value).send({ from: sender });

      await loadVoters();

      newVoter = "";
    }

    return {
      newVoter,
      votersList,
      registerVoter,
    };
  },
};
</script>
