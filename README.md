# 🌀 ZK-ETH-Mixer : A Private ETH Mixer Using Poseidon Commitments

> A zero-knowledge mixer protocol inspired by [Tornado Cash](https://tornado.cash) enabling anonymous on-chain transfers using zk-SNARKs and Poseidon-based commitments.

---

## 📌 Overview

ZK-ETH-Mixer is a privacy-focused smart contract protocol that allows users to deposit and withdraw cryptocurrency in a completely anonymous way. It uses zero-knowledge proofs to unlink the sender and recipient addresses, making on-chain analysis ineffective.

This implementation uses:

- **Poseidon Hash** for zk-friendly Merkle commitments.
- **Noir** for building custom zk-SNARK circuits.
- **Hardhat** and **Ethers.js** for Ethereum development and interaction.
- **zk-SNARK verifier** deployed on-chain to validate anonymous proofs.

---

## 🎯 Key Features

- ✅ Anonymous deposits and withdrawals
- 🔒 Poseidon hash-based commitments
- 🌳 Merkle tree structure for anonymity set
- ✨ Zero-knowledge proof verification
- 💸 Fixed denomination ETH transfers
- 🧾 Nullifier system to prevent double-spending

---

## 🧠 How It Works

### 📥 Deposit Phase

1. User generates a `(secret, nullifier)` pair.
2. Computes `commitment = PoseidonHash(secret, nullifier)`.
3. Sends a fixed amount (e.g., `0.1 ETH`) with the `commitment` to the contract.
4. The contract inserts the commitment into a Merkle tree and stores it on-chain.

### 📤 Withdraw Phase

1. User generates a zk-SNARK proof showing:
   - They know a secret pair `(secret, nullifier)` that hashes to a commitment in the tree.
   - The nullifier hasn’t been used before.
2. User submits the proof and `nullifierHash` to the contract.
3. If valid, the contract:
   - Verifies the proof on-chain
   - Transfers ETH to the specified recipient
   - Marks the `nullifierHash` as spent

---

## 🛠 Tech Stack

| Component       | Tech             |
| --------------- | ---------------- |
| Smart Contracts | Solidity         |
| ZK Circuits     | Noir + SnarkJS   |
| Hashing         | Poseidon         |
| Testing         | Hardhat + Mocha  |
| Interaction     | Ethers.js        |
| Frontend (opt)  | React + Tailwind |

---

## 🧪 Local Development Setup

### ✅ Prerequisites

- Node.js (v18+)
- Yarn or NPM
- Hardhat
- Noir
- SnarkJS

### 📦 Install

```bash
git clone https://github.com/your-username/ZK-ETH-Mixer.git
cd tornado-clone

# Install dependencies
yarn install
# or
npm install
```

### 🛠 Build ZK Circuit

```bash
cd circuits/
Noir mixer.nr --r1cs --wasm --sym
cd mixer_js/
node generate_witness.js mixer.wasm input.json witness.wtns
snarkjs groth16 setup mixer.r1cs pot12_final.ptau mixer_0000.zkey
snarkjs zkey contribute mixer_0000.zkey mixer_final.zkey
snarkjs zkey export verificationkey mixer_final.zkey verification_key.json
```

### 🧪 Test Smart Contracts

```bash
cd ..
npx hardhat test
```

---

## 💡 Architecture

```
├── contracts/
│   ├── ZK-ETH-Mixer.sol        # Main mixer contract
│   └── Verifier.sol            # zk-SNARK proof verifier
├── circuits/
│   └── mixer.nr            # ZK circuit (Poseidon hash, Merkle inclusion)
├── scripts/
│   └── deploy.js               # Deployment scripts
├── test/
│   └── mixer.test.js           # Unit tests (deposit/withdraw/proof)
├── frontend/ (optional)
│   └── React UI (connect wallet, deposit, withdraw)
```

---

## 📤 Usage Flow

1. **User generates:** secret, nullifier → computes commitment.
2. **Deposits ETH** via `deposit(commitment)` function.
3. **Waits** for more users (anonymity set grows).
4. **Generates proof** off-chain (using witness data + zk key).
5. **Calls `withdraw(proof, root, nullifierHash, recipient)`** on-chain.
6. **Receives ETH** privately at recipient address.

---

## 📈 Future Enhancements

- 🪙 ERC20 support
- 🪂 Relayer integration (for true privacy)
- 🧾 Better UI/UX with React
- 🌍 IPFS or off-chain state syncing
- 🔁 Cross-chain mixer (L2, zkSync, Polygon)

---

## 👨‍💻 Contributing

Contributions are welcome! Please open issues or pull requests.

```bash
# Run linter and tests before submitting PR
npx hardhat test
npm run lint
```

---

## 📜 License

MIT License © 2025 YourName

> ⚠️ For educational and research purposes only. This repository is not intended for production use. Always consult legal experts before deploying any privacy-preserving application to a public blockchain.

---

## 🧠 Credits & Resources

- [Tornado Cash](https://tornado.cash/)
- [Poseidon Hash](https://eprint.iacr.org/2019/458.pdf)
- [Noir Docs](https://docs.noir.io)
- [ZK Learning](https://zk-learning.org/)
- [ZK Hack](https://zkhack.dev/)
