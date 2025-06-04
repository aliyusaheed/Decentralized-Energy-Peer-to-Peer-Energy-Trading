# Decentralized Energy Peer-to-Peer Trading Platform

A blockchain-based peer-to-peer energy trading platform built with Clarity smart contracts, enabling direct energy transactions between producers and consumers while integrating with existing grid infrastructure.

## Overview

This platform facilitates decentralized energy trading by connecting renewable energy producers directly with consumers, eliminating intermediaries and enabling fair price discovery through market mechanisms.

## System Architecture

### Core Smart Contracts

1. **Energy Producer Verification Contract** (`energy-producer-verification.clar`)
    - Validates and registers energy producers
    - Manages producer credentials and certifications
    - Tracks production capacity and history

2. **Energy Trading Contract** (`energy-trading.clar`)
    - Facilitates peer-to-peer energy transactions
    - Manages buy/sell orders
    - Handles energy transfer agreements

3. **Grid Integration Contract** (`grid-integration.clar`)
    - Integrates P2P trading with existing grid infrastructure
    - Manages grid stability and load balancing
    - Coordinates with utility providers

4. **Price Discovery Contract** (`price-discovery.clar`)
    - Implements dynamic pricing mechanisms
    - Calculates market rates based on supply/demand
    - Manages price history and trends

5. **Settlement Processing Contract** (`settlement-processing.clar`)
    - Processes completed energy trades
    - Handles payment settlements
    - Manages dispute resolution

## Features

- ✅ Decentralized energy producer verification
- ✅ Automated peer-to-peer energy trading
- ✅ Real-time price discovery
- ✅ Grid integration and stability management
- ✅ Automated settlement processing
- ✅ Transparent transaction history
- ✅ Dispute resolution mechanisms

## Getting Started

### Prerequisites

- Clarity CLI
- Node.js (v16 or higher)
- Vitest for testing

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-org/decentralized-energy-trading.git
cd decentralized-energy-trading
```

2. Install dependencies:
```bash
npm install
```

3. Deploy contracts to local testnet:
```bash
clarinet deploy --testnet
```

### Running Tests

Execute the test suite using Vitest:

```bash
npm test
```

Run specific test files:

```bash
npm test energy-producer-verification.test.js
npm test energy-trading.test.js
npm test price-discovery.test.js
```

## Contract Interactions

### Producer Registration

```clarity
;; Register as an energy producer
(contract-call? .energy-producer-verification register-producer 
  "Solar Farm Alpha" 
  u1000 ;; capacity in kWh
  "renewable-solar")
```

### Creating Energy Offers

```clarity
;; Create an energy sell offer
(contract-call? .energy-trading create-sell-offer 
  u500 ;; energy amount in kWh
  u50  ;; price per kWh in micro-STX
  u144) ;; duration in blocks
```

### Buying Energy

```clarity
;; Purchase energy from an offer
(contract-call? .energy-trading buy-energy 
  u1 ;; offer ID
  u200) ;; energy amount to purchase
```

## API Reference

### Energy Producer Verification

- `register-producer(name, capacity, energy-type)` - Register new energy producer
- `verify-producer(producer-id)` - Verify producer credentials
- `get-producer-info(producer-id)` - Retrieve producer details

### Energy Trading

- `create-sell-offer(amount, price, duration)` - Create energy sell offer
- `create-buy-request(amount, max-price)` - Create energy buy request
- `buy-energy(offer-id, amount)` - Purchase energy from offer
- `cancel-offer(offer-id)` - Cancel existing offer

### Price Discovery

- `get-current-price()` - Get current market price
- `calculate-dynamic-price(supply, demand)` - Calculate price based on market conditions
- `get-price-history(blocks)` - Retrieve historical price data

### Settlement Processing

- `process-settlement(trade-id)` - Process completed trade settlement
- `initiate-dispute(trade-id, reason)` - Initiate dispute resolution
- `resolve-dispute(dispute-id, resolution)` - Resolve trade dispute

## Testing Strategy

The project uses Vitest for comprehensive testing:

- **Unit Tests**: Individual contract function testing
- **Integration Tests**: Multi-contract interaction testing
- **Scenario Tests**: End-to-end trading scenarios
- **Edge Case Tests**: Error handling and boundary conditions

### Test Structure

```
tests/
├── unit/
│   ├── energy-producer-verification.test.js
│   ├── energy-trading.test.js
│   ├── grid-integration.test.js
│   ├── price-discovery.test.js
│   └── settlement-processing.test.js
├── integration/
│   ├── trading-flow.test.js
│   └── settlement-flow.test.js
└── scenarios/
    ├── peak-demand.test.js
    └── grid-stability.test.js
```

## Configuration

### Environment Variables

```bash
# Network configuration
NETWORK=testnet
RPC_ENDPOINT=https://stacks-node-api.testnet.stacks.co

# Contract deployment
DEPLOYER_PRIVATE_KEY=your_private_key_here
CONTRACT_ADDRESS=ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM
```

## Security Considerations

- All contracts implement access controls
- Producer verification prevents fraudulent participants
- Settlement processing includes dispute resolution
- Grid integration ensures system stability
- Price manipulation protection through decentralized discovery

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Write tests for your changes
4. Ensure all tests pass: `npm test`
5. Submit a pull request

### Development Guidelines

- Follow Clarity best practices
- Write comprehensive tests for all functions
- Document all public contract functions
- Ensure gas efficiency in contract design

## Roadmap

- [ ] Mobile app integration
- [ ] Advanced analytics dashboard
- [ ] Multi-chain support
- [ ] IoT device integration
- [ ] Machine learning price prediction
- [ ] Carbon credit integration

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions and support:
- Create an issue on GitHub
- Join our Discord community
- Email: support@energy-trading.com

## Acknowledgments

- Stacks blockchain community
- Clarity language contributors
- Renewable energy advocates
- Open source testing frameworks
```

