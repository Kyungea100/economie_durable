<template>
  <EnregistrementVoter v-show="!proposition" />
  <button @click="handleClick" v-if="!proposition">
    Enregistrer propositions
  </button>
  <button @click="handleClick" v-if="proposition">
    Enregistrer électeurs
  </button>
  <EnregistrementProposal v-if="proposition" />
</template>

<script>
import EnregistrementVoter from "@/components/enregistrementVoter.vue";
import EnregistrementProposal from "@/components/enregistrementProposal.vue";
import { ref } from "vue";

export default {
  name: "App",
  components: {
    EnregistrementProposal,
    EnregistrementVoter,
  },
  setup() {
    let proposition = ref(false);
    function handleClick() {
      proposition.value = !proposition.value;
    }
    return {
      handleClick,
      proposition,
    };
  },
};
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
