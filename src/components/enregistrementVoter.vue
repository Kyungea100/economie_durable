<template>
  <div>
    <h2>Enregistrement des Electeurs</h2>
    <div>
      <label for="voterInput">Adresse du nouvel électeur :</label>
      <input type="text" id="voterInput" v-model="newVoter" />
      <button @click="registerVoter">Enregistrer électeur</button>
    </div>

    <h2>Liste des électeurs enregistrés</h2>
    <ul>
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
      "0x99d1AA69dF4Cf58ac4b367f8F5fea08303C73931"
    );
    //remplacer l'adresse par celle qui s'affiche au déploiement du contrat

    async function loadVoters() {
      const voterCount = contractInstance.methods.getVoterCount().call();
      console.log(voterCount);
      for (let i = 0; i < voterCount; i++) {
        const voterList = await contractInstance.methods.getVoters().call();
        votersList.value.push(voterList[i]);
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
    }

    return {
      newVoter,
      votersList,
      registerVoter,
    };
  },
};
</script>
