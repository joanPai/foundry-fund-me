-include .env

compile:;
	forge compile

sepolia:;
	forge script script/DeployFundMe.s.sol --rpc-url $(SEPOLIA_RPC) --account woah --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
anvil:;
	forge script script/DeployFundMe.s.sol --rpc-url $(RPC_URL) --account pondr --broadcast -vv