# PhoenixTokenPHX
Personal Cryptocurrency Coin, ERC-20 Contract Coded in REMIX

# Phoenix (PHX) on BSC

- I wrote a simple ERC-20-style token with a few knobs (fee, cooldown, anti-whale, pause).
- Deployed multiple times on Remix + MetaMask for testing, then pushed to BNB Smart Chain mainnet.
- Set up a PHX/BNB pool on PancakeSwap V2 so it’s actually buyable/sellable with liquidity.
- Might add a JSON token list + logo later so the icon shows up in UIs.

## Live stuff and Purchase info, please purchase token by using link below on METAMASK wallet
**Token (PHX):** 0x2afe1d047e47e7b97D7a4EA400bc1c7350f7Ff28
**BscScan:** https://bscscan.com/address/0x2afe1d047e47e7b97D7a4EA400bc1c7350f7Ff28
**Buy on Pancake (direct link):** https://pancakeswap.finance/swap?outputCurrency=0x2afe1d047e47e7b97D7a4EA400bc1c7350f7Ff28&chain=bsc

## How to buy (quick)

1. Switch your wallet to **BNB Smart Chain (BSC)**.
2. Open the **Buy on Pancake** link above.
3. Import PHX if prompted (it’s new, so it shows the “unknown token” warning).
4. Set **slippage to ~3%** (PHX has a 1% transfer fee on non-owner transfers).
5. Swap **BNB → PHX** (start small on a fresh pool to avoid price-impact warnings).

## Token basics
- **Decimals:** 18
- **Initial supply:** 630,000 PHX (to owner at deploy)
- **Fee:** 1% on non-owner transfers (goes to owner)
- **Cooldown:** default 10s (I set it to 0 for DEX trading)
- **Max tx / max wallet:** adjustable (I set big values at launch so swaps don’t revert)

## Notes I ran at launch
- setCooldown(0)
- setMaxTx(1_000_000 * 10^18)
- setMaxWallet(1_000_000 * 10^18)
- Recommended swap slippage for buyers: **3%** 

## Disclaimer

This is a learning/demo project. No promises of value; use at your own risk. Nothing here is financial advice.

## License

MIT
