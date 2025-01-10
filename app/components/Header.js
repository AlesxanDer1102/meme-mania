import { ethers } from "ethers";

function Header({ account, setAccount }) {
  async function connectWallet() {
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    const account = ethers.getAddress(accounts[0]);
    setAccount(account);
  }
  return (
    <header>
      <p className="brand" style={{ padding: "1em" }}>
        Meme.Mania
      </p>
      {account ? (
        <button className="btn--fancy">
          [{account.slice(0, 6) + "..." + account.slice(38, 42)}]
        </button>
      ) : (
        <button onClick={connectWallet} className="btn--fancy">
          Connect Wallet
        </button>
      )}
    </header>
  );
}

export default Header;
