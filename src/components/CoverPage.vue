<template>
    <div class="my-auto container">
      <div class="my-auto" style="display: block;">
        <h2 class="text-light ">Blockchain Based Voting System</h2>
        <span class="text-light"> A decentralized voting system that is built on the Ethereum blockchain.</span>
      <br/>
        <b-button style="background: white;color: black;font-weight: 400;" class="mt-5" >Enter the Voting System</b-button >
      </div>
  
    </div>
  </template>
  <script>
  import { ethers } from "ethers";
  // import contractAbi from "../contracts/abi/ballot.json"
  
  export default {
    data() {
      return {
        message: 'Blockchain Voting System',
        provider: null,
        accounts: [],
        balance: 0,
        contract: null,
        candidatesLength: 0,
        candidates: [],
        errorMessage: "",
        voted: false,
        name: null,
        nameState: null,
      }
  
    },
  
    methods: {
      async getUnits() {
        console.log("check")
        this.provider = new ethers.providers.Web3Provider(window.ethereum)
        this.accounts = await this.provider.send('eth_requestAccounts', [])
      }
    },
    beforeMount() {
      this.getUnits()
    },
  }
  </script>
  <style>
  h4.candidate-name {
    color: gray;
  }
  
  body {
    font-family: "Odibee Sans", cursive;
    background-image: url("https://images.unsplash.com/photo-1639322537228-f710d846310a?auto=format&fit=crop&w=1400")
  }
  
  .container {
    height: 100vh;
    vertical-align: middle;
    display: flex;
    flex-direction: column;
  }
  
  .candidate-card {
    border: 1px solid black;
  }
  
  .form-container {
    border: 1px solid black;
    padding: 10px;
    width: 500px;
  }
  </style>