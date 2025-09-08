import { useConnect, useDisconnect, useAccount } from "wagmi"

export const ConnectWallet = () => {
    const { connect, connectors } = useConnect();
    const { address, isConnected } = useAccount();
    const { disconnect } = useDisconnect();
    if(isConnected) {
        return (
            <div>
                Connected: {address}
                <button onClick={()=>{disconnect()}}>Disconnect</button>
            </div>
        )
    }

    return (
        <div>
            {connectors.map((connector)=>(
                <button key={connector.uid} onClick={()=>connect({connector})}>Connect with {connector.name}</button>
            ))}
        </div>
    );
}
