import { http, createConfig } from "wagmi";
import { sepolia } from "wagmi/chains";
import { injected, metaMask } from "wagmi/connectors";

const rpcUrl = "";

export const config = createConfig({
    chains: [sepolia],
    connectors: [
        injected(),
        metaMask()
    ],
    transports: {
        [sepolia.id]: http(rpcUrl)
    }
})