"use client";

import { useEffect, useState } from "react";
import { ethers } from "ethers";

// Components
import Header from "./components/Header";
import List from "./components/List";
import Token from "./components/Token";
import Trade from "./components/Trade";

// ABIs & Config
import Factory from "./abis/Factory.json";
import config from "./config.json";
import images from "./images.json";

export default function Home() {
  const [provider, setProvider] = useState(null);
  const [account, setAccount] = useState(null);
  const [factory, setFactory] = useState(null);
  const [fee, setFee] = useState(0);
  const [showCreate, setShowCreate] = useState(false);
  const [token, setToken] = useState(null);
  const [tokens, setTokens] = useState([]);
  const [showTrade, setShowTrade] = useState(false);

  function togleCreate() {
    setShowCreate(!showCreate);
  }
  function toggleTrade(token) {
    setToken(token);
    setShowTrade(!showTrade);
  }

  async function loadBlockChainData() {
    const provider = new ethers.BrowserProvider(window.ethereum);
    setProvider(provider);
    const network = await provider.getNetwork();

    const factory = new ethers.Contract(
      config[network.chainId].factory.address,
      Factory,
      provider
    );

    setFactory(factory);

    const fee = await factory.fee();
    setFee(fee);

    const totalTokens = await factory.totalTokens();
    const tokens = [];

    for (let i = 0; i < totalTokens; i++) {
      if (i == 6) {
        break;
      }
      const tokenSale = await factory.getTokenSale(i);

      const token = {
        token: tokenSale.token,
        name: tokenSale.name,
        creator: tokenSale.creator,
        sold: tokenSale.sold,
        raised: tokenSale.raised,
        isOpen: tokenSale.isOpen,
        image: images[i],
      };
      tokens.push(token);
    }
    console.log(tokens);
    setTokens(tokens.reverse());
  }
  useEffect(() => {
    loadBlockChainData();
  }, []);

  return (
    <div className="page">
      <Header account={account} setAccount={setAccount} />
      <main>
        <div className="create">
          <button onClick={togleCreate} className="btn--fancy">
            {!factory
              ? "[Contract not Deployed]"
              : !account
              ? "[Connect Wallet]"
              : "[Crete New Token]"}
          </button>
        </div>
        <div className="listings">
          <h1>new listings</h1>
          <div className="tokens">
            {!account ? (
              <p>Please conect the walelt</p>
            ) : tokens.length === 0 ? (
              <p>Not token listed</p>
            ) : (
              tokens.map((token, index) => (
                <Token toggleTrade={toggleTrade} token={token} key={index} />
              ))
            )}
          </div>
        </div>
      </main>
      {showCreate && (
        <List
          toggleCreate={togleCreate}
          provider={provider}
          factory={factory}
          fee={fee}
        />
      )}
      {showTrade && (
        <Trade
          toggleTrade={toggleTrade}
          provider={provider}
          factory={factory}
          account={account}
          token={token}
        />
      )}
    </div>
  );
}
