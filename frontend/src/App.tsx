import { WagmiProvider } from "wagmi";
import { config } from "./config";
import { Panagram } from "./components/Panagram";
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

const queryClient = new QueryClient();

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <Panagram />
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App
