import { use, useEffect, useState } from "react";
import { ethers } from "ethers";

function Trade({ toggleTrade, token, provider, factory }) {
  const [target, setTarget] = useState(null);
  const [limit, setLimit] = useState(null);
  const [cost, setCost] = useState(null);

  async function buyHandler(e) {
    const amount = e.get("amount");
    const cost = await factory.getCost(token.sold);
    const totalCost = cost * BigInt(amount);

    const signer = await provider.getSigner();
    const trasaction = await factory
      .connect(signer)
      .buy(token.token, ethers.parseUnits(amount, 18), { value: totalCost });

    await trasaction.wait();

    toggleTrade();
  }
  async function getSaleDetails() {
    const target = await factory.TARGET();
    const limit = await factory.TOKEN_LIMIT();
    const cost = await factory.getCost(token.sold);
    setTarget(target);
    setLimit(limit);
    setCost(cost);
  }

  useEffect(() => {
    getSaleDetails();
  }, []);

  return (
    <div className="trade">
      <h2>Trade</h2>

      <div className="token__details">
        <p className="name">{token.name}</p>
        <p>
          creator:{" "}
          {token.creator.slice(0, 6) + "..." + token.creator.slice(38, 42)}
        </p>
        <img src={token.image} alt="Pepe" width={256} height={256} />
        <p>marketcap: {ethers.formatUnits(token.raised, 18)} ETH</p>
        <p>base cost: {cost ? ethers.formatUnits(cost, 18) : "0"} ETH</p>
      </div>
      {token.sold >= limit || token.raised >= target ? (
        <p className="disclaimer">target reached!</p>
      ) : (
        <form action={buyHandler}>
          <input
            type="number"
            name="amount"
            min={1}
            max={10000}
            placeholder="1"
          />
          <input type="submit" value="[buy]" />
        </form>
      )}

      <button onClick={toggleTrade} className="btn--fancy">
        Cancel
      </button>
    </div>
  );
}

export default Trade;
