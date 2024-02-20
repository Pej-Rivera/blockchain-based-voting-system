<template>
  <b-container fluid class="app">
     <CandidatesList /> 
  </b-container>
</template>

<script>
 import CandidatesList from './components/CandidatesList.vue';


export default {
  name: 'App',
  components: {
    CandidatesList,
  }
}
</script>

<style scoped>
.app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: "black";
  margin: 20px 0px;
}



@import'~bootstrap/dist/css/bootstrap.css'
</style>
