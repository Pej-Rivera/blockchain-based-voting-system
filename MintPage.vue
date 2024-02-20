<template>
  <div>
    <h1>NFT Minting Page</h1>
    <div class="m-3">
      <div class="text-center mt-3" v-if="accounts.length === 0">Account Address: </div>
      <div class="text-center mt-3" v-else>Account Address: {{ accounts[0] }}</div>
      <b-button class="text-center mt-2" @click="mintNft()" style="background-color: #00356B;">Mint NFT</b-button>
      <div>
        <div class="nft-container mt-5">
          <div v-for="(nft, index) in nfts" :key="index" class="nft-card">
            <h5>Token #{{ nft.tokenId }}</h5>
            <img class="mb-2" :src="getImgUrl(nft.image)" height="150" />
            <div>
              <strong>{{ nft.name }}</strong>
            </div>
            <p class="mt-1">{{ nft.description }}</p>
            <div v-for="(attr, index2) in nft.attributes" :key="index2">
              <strong>{{ attr.trait_type }}</strong> - {{ attr.value }}
            </div>

          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { ethers } from "ethers";
import erc721Abi from "../contracts-abi/erc721Abi.json"
import pokeUrl from "../../pokemon_url.json"
import axios from "axios";

export default {
  data() {
    return {
      nfts: [],
      provider: null,
      accounts: [],
      balance: 0,
      contract: null,
      nftContract: null,
    }

  },
  methods: {
    // Function that opens metamask window extension to connect wallet
    async connectWallet() {
      this.provider = new ethers.providers.Web3Provider(window.ethereum)
      this.accounts = await this.provider.send('eth_requestAccounts', [])
      this.createContractInstance()

    },
    // Function that creates contract instance
    async createContractInstance() {
      var contractAddress = '0xdBd2A7af9568030793a324a0662D8258804E886d'
      this.contract = new ethers.Contract(contractAddress, erc721Abi)
      this.contract = this.contract.connect(this.provider)
      this.getOwnedNfts();
    },
    async mintNft() {
      var signer = this.provider.getSigner()
      var nftContractWithSigner = await this.contract.connect(signer)
      try {
        var mint = await nftContractWithSigner.mint()
        await mint.wait()
        window.alert('Minted new NFT!')

      } catch (error) {
        console.log(error)
      }
      this.getOwnedNfts();
    },
    async getOwnedNfts() {
      var signer = this.provider.getSigner()
      var nftContractWithSigner = await this.contract.connect(signer)
      var ownedTokensLength = await nftContractWithSigner.ownerTokensLength(this.accounts[0])

      this.nfts = [];
      for (var i = 0; i < ownedTokensLength; i++) {
      
        var tokenId = await nftContractWithSigner.ownerTokens(this.accounts[0], i)
        var tokenUrl = "https://ipfs.io/" + pokeUrl[parseInt(tokenId)].IPFS_URL

        console.log(tokenUrl)
        var response = await axios.get(tokenUrl)
        response.data.tokenId = tokenId
        this.nfts.push(response.data)
      }

    },
    getImgUrl(path) {
      var res = path.replace("ipfs://", "ipfs/");
      return 'http://127.0.0.1:8081/' + res;
    },
    generateRandomNumber() {
      // Create an array with numbers from 1 to 50
      var numbers = Array.from({ length: 28 }, (_, i) => i + 1);

      // Shuffle the array using Fisher-Yates algorithm
      for (var i = numbers.length - 1; i > 0; i--) {
        var j = Math.floor(Math.random() * (i + 1));
        [numbers[i], numbers[j]] = [numbers[j], numbers[i]];
      }

      // Get and remove the last element from the shuffled array
      return numbers.pop();
    }
  },
  beforeMount() {
    this.connectWallet()
  },
}
</script>
<style scoped>
.nft-card {
  background-color: #eee;
  border-radius: 5px;
  box-shadow: #9a9a9a 2px 2px 3px;
  width: 30%;
  padding: 15px;
  margin: 20px;
}

.nft-attr {
  border: 1px solid black;
  border-radius: 5px;
  margin-bottom: 5px;
}

.nft-container {
  width: 100%;
  flex-wrap: wrap;
  display: flex;
}
</style>
