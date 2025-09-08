import { WagmiProvider } from "wagmi";
import { config } from "./config";

function App() {
  return (
    <WagmiProvider config={config}>
      
    </WagmiProvider>
  );
}

export default App
