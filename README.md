Контракт с уровнями доступа: Реализовано через AccessControlUpgradeable (роли DEFAULT_ADMIN_ROLE и MINTER_ROLE).

Мета-транзакции + permit (ERC-2612): Реализовано. Функция permit позволяет пользователю подписать разрешение на трату токенов (approve) оффлайн, а транзакцию в сеть отправит и оплатит газом кто-то другой (проверка в тесте testPermitMetaTx).

Обновляемый контракт по одному из стандартов: Выбран стандарт Beacon.

Factory контракт, создающий клоны: Фабрика создает BeaconProxy, которые являются клонами с точки зрения переиспользования логики.

Тесты: Написан минимальный набор тестов в Foundry.

Сборка и тесты:

forge install openzeppelin/openzeppelin-contracts

forge install openzeppelin/openzeppelin-contracts-upgradeable

forge test -v


Деплой V1:

source .env

forge script script/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv


Создаем новый токен:

cast send 0x3EC6ba6566bD5D139d31c822B304790919a239f9 "createToken(string,string,address)" "GustavToken" "GUST" 0xC1FA18311814337b85c72936688aeb1F5327609e --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY


Узнаем адрес созданного токена:

cast call 0x3EC6ba6566bD5D139d31c822B304790919a239f9 "allBeaconProxies(uint256)(address)" 0 --rpc-url $SEPOLIA_RPC_URL


Минтим токены на клоне:

cast send 0xC2fF5ceB0916dB7E3aF39c8632Bdc70c6D194ec5 "mint(address,uint256)" 0xC1FA18311814337b85c72936688aeb1F5327609e 1000000000000000000000 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY


Проверяем баланс на клоне:

cast call 0xC2fF5ceB0916dB7E3aF39c8632Bdc70c6D194ec5 "balanceOf(address)(uint256)" 0xC1FA18311814337b85c72936688aeb1F5327609e --rpc-url $SEPOLIA_RPC_URL


Деплой V2:

forge create src/TokenUpgradeableV2.sol:TokenUpgradeableV2 --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast


Переключаем Маяк (Beacon) на новую логику:

cast send 0x7396CeC0C8e90d06EedAbB1B4760d53C120E712d "upgradeTo(address)" 0xF29d09632ce376dF509DBC3Fa645d72802C3B4BE --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY


Вызываем новую функцию:

cast call 0xC2fF5ceB0916dB7E3aF39c8632Bdc70c6D194ec5 "version()(string)" --rpc-url $SEPOLIA_RPC_URL


Проверяем, что баланс не обнулился и остался прежним:

cast call 0xC2fF5ceB0916dB7E3aF39c8632Bdc70c6D194ec5 "balanceOf(address)(uint256)" 0xC1FA18311814337b85c72936688aeb1F5327609e --rpc-url $SEPOLIA_RPC_URL





