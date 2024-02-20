<template>
  <div>
    <div class="container">
      <b-navbar toggleable="lg" type="" variant="" class="p-0">
        <b-navbar-brand class="text-dark" href="#">Blockchain Based Voting System</b-navbar-brand>
        <!-- Right aligned nav items -->
        <b-navbar-nav class="ml-auto">
          <b-navbar-nav>
            <b-nav-item href="#" disabled v-if="role === 1">
              <p style="color: black!important">Admin</p>
            </b-nav-item>

            <b-nav-item href="#" disabled v-else-if="role === 2">
              <p style="color: #3F704D!important">Registered Voter</p>
            </b-nav-item>
            <b-nav-item href="#" disabled v-else>
              <p style="color: #800000!important">Unregistered Voter</p>
            </b-nav-item>
          </b-navbar-nav>
        </b-navbar-nav>
      </b-navbar>

      <h5 v-if="electionState === 0" class="text-dark mt-5">
        Election Status: Election has not started.
      </h5>
      <h5 v-else-if="electionState === 1" class="text-dark mt-5">
        Election Status: Election is in progress.
      </h5>
      <h5 v-else class="text-dark mt-5">
        Election Status: Election has ended.
      </h5>
      <div class="m-3">
        <div class="text-center mt-3 text-black-50" v-if="accounts.length === 0">Account Address: </div>
        <div class="text-center mt-3 text-black-50" v-else>Account Address: {{ accounts[0] }}</div>
        <b-button block class="text-center mt-2" v-if="electionState === 0 && role === 1" v-b-modal.modal-start-election
          style="background-color: #00356B;">Start the Election</b-button>
        <b-button block class="text-center mt-2" v-if="electionState === 1 && role === 1" v-b-modal.modal-end-election
          style="background-color: #00356B;">Stop the Election</b-button>
        <div class="text-center mt-5" v-if="role === 1 && electionState === 0">
          <hr style="border-color:white" />
          <b-form-input style="background: transparent;color: gray;" v-model="address" :state="addressState"
            placeholder="Account Address"></b-form-input>


          <b-button block class="text-center mt-2" @click="addVoter()" style="background-color: #00356B;">Add
            Voter</b-button>
        </div>

        <div class="text-center mt-5" v-if="role === 1 && electionState === 0">
          <hr style="border-color:white" />

          <b-form-input style="background: transparent;color: gray;" v-model="name" :state="nameState"
            placeholder="Candidate Name"></b-form-input>


          <b-button block class="text-center mt-2" @click="addCandidate()" style="background-color: #00356B;">Add
            Candidate</b-button>
        </div>
        <hr style="border-color:white" />
        <h5 style="color: gray;">List of Candidates</h5>
        <div>
          <div class="d-flex mt-2">
            <b-card v-for="(candidate, index) in candidates" :key="index" class="m-3" style="max-width: 20rem;">
              <b-card-title>
                <img :src="candidate.image" alt="Candidate Image" height="130x" width="130px" />
              </b-card-title>
              <b-card-title>
                {{ candidate.name }}
              </b-card-title>
              <b-card-text v-if="electionState !== 0">
                Vote Count: {{ candidate.voteCount }}
              </b-card-text>
              <div v-if="role === 2 && electionState === 1 && !voted">
                <b-form-radio v-model="selectedIndex" :aria-describedby="ariaDescribedby" :value="index"
                  name="candidate-radio"></b-form-radio>
              </div>
            </b-card>

          </div>
          <b-button v-if="role === 2 && electionState === 1 && !voted" block class="mt-3" @click="vote()"
            style="background-color: #00356B;">Vote</b-button>

          <p v-if="role === 2 && electionState === 1 && voted" class="text-black-50 mt-3">Your vote has been cast.</p>

          <h4 v-if="electionState === 2" class="text-black-50 mt-5">Congratulations to our newly elected President! 🥳
          </h4>
          <h4 v-if="electionState === 2" class="text-black-50 mt-3">{{ electionWinner }} </h4>
        </div>

      </div>
    </div>
    <b-modal id="modal-start-election" ref="modal" title="Alert" @ok="startElection">
      <div class="d-block">Are you sure you want to start the election? </div>
    </b-modal>
    <b-modal id="modal-end-election" ref="modal" title="Alert" @ok="endElection">
      <div class="d-block">Are you sure you want to end the election? </div>
    </b-modal>
  </div>
</template>
<script>
import { ethers } from "ethers";
import contractAbi from "../contracts-abi/ballot.json"

export default {
  data() {
    return {
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
      electionState: null,
      role: null,
      address: null,
      addressState: null,
      selectedIndex: null,
      electionWinner: null,
    }

  },

  methods: {
    // Function that opens metamask window extension to connect wallet
    async connectWallet() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      this.accounts = await this.provider.send('eth_requestAccounts', [])
      this.createContractInstance()
      this.getElectionStatus()
      this.getCandidates()
      this.getRole()
    },
    // Function that creates contract instance
    async createContractInstance() {
      var contractAddress = '0x72199A58707E0306ec361563b2fb905b7BAbA08e'
      this.contract = new ethers.Contract(contractAddress, contractAbi)
      this.contract = this.contract.connect(this.provider)

    },
    // Function to register provided account address 
    async addVoter() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      try {
        var transaction = await contractWithSigner.addVoter(this.address)
        await transaction.wait()
        this.makeToast('success', "Success", "Voter successfully added!")
        this.getCandidates()
      } catch (error) {
        console.log(error.data.data.reason)
        this.makeToast('danger', "Error", error.data.data.reason)
      }
      this.address = null;
    },
    async startElection() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      try {
        var transaction = await contractWithSigner.startElection()
        await transaction.wait()
        this.makeToast('success', "Success", "Election started successfully!")
        this.getElectionStatus()
      } catch (error) {
        console.log(error.data.data.reason)
        this.makeToast('danger', "Error", error.data.data.reason)
      }
    },
    async endElection() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      try {
        var transaction = await contractWithSigner.endElection()
        await transaction.wait()
        this.makeToast('success', "Success", "Election ended successfully!")
        this.getElectionStatus()
      } catch (error) {
        console.log(error.data.data.reason)
        this.makeToast('danger', "Error", error.data.data.reason)
      }
    },
    // Function that gets the role of the current account connected
    async getRole() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      const role = await contractWithSigner.getRole(await signer.getAddress());
      this.role = parseInt(role)
    },
    // Function that executes voting feature
    async vote() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      try {
        var transaction = await contractWithSigner.vote(this.selectedIndex)
        await transaction.wait()
        this.voted = true
        this.makeToast('success', "Success", "User successfully voted!")
        this.getCandidates()

      } catch (error) {
        console.log(error.data.data.reason)
        this.makeToast('danger', "Error", error.data.data.reason)
      }
      this.selectedIndex = null
    },
    // Function for getting election status
    async getElectionStatus() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      const electionStatus = await contractWithSigner.electionState();
      console.log(electionStatus)
      this.electionState = electionStatus
      if (electionStatus === 2) {
        this.getWinner();
      }
      const voteStatus = await contractWithSigner.voted(await signer.getAddress());
      this.voted = voteStatus

    },
    // Function that pulls all added candidates in the smart contract
    async getCandidates() {
      this.candidatesLength = await this.contract.getCandidatesLength()
      this.candidates = [];
      for (let i = 0; i < this.candidatesLength; i++) {
        var candidate = await this.contract.candidates(i)
        var _candidate = {
          name: candidate.name,
          voteCount: candidate.voteCount,
          image: 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + candidate.name,

        }
        this.candidates.push(_candidate)
      }
    },
    checkFormValidity() {
      const valid = this.$refs.form.checkValidity()
      this.nameState = valid
      return valid
    },
    makeToast(variant = null, title = null, message = null) {
      this.$bvToast.toast(`${message}`, {
        title: `${title}`,
        variant: variant,
        solid: true,
        toaster: "b-toaster-top-right",
      })
    },
    // Function for adding candidate
    async addCandidate() {
      var signer = this.provider.getSigner()
      var contractWithSigner = await this.contract.connect(signer)
      try {
        var transaction = await contractWithSigner.addCandidate(this.name)
        await transaction.wait()
        this.makeToast('success', "Success", "Candidate successfully added!")
        this.getCandidates()
      } catch (error) {
        console.log(error.data.data.reason)
        this.makeToast('danger', "Error", error.data.data.reason)
      }
      this.name = null
    },
    async getWinner() {
      var winner = await this.contract.getWinner()
      this.electionWinner = winner
    }
  },
  beforeMount() {
    this.connectWallet()
  },
}
</script>
<style>
h4.candidate-name {
  color: gray;
}

body {
  font-family: "Odibee Sans", cursive;
  background: #f2f2f2;
}

.containers {
  background-color: #eee;
  width: 1060px;
  margin: auto;
  padding: 10px;
  border-radius: 10px;
  box-shadow: #9a9a9a 2px 2px 3px;
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