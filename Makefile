
.PHONY: dev prod setup-ca artifacts network join deploy clean devmode-on devmode-off

dev: setup-ca artifacts devmode-on network join deploy
	./scripts/dev-env.sh

prod: setup-ca artifacts network join deploy
	./scripts/prod-env.sh

setup-ca:
	./scripts/setup-ca.sh

artifacts:
	./scripts/generate-artifacts.sh

devmode-on:
	./scripts/toggle-dev-mode.sh enable

devmode-off:
	./scripts/toggle-dev-mode.sh disable

network:
	./scripts/start-network.sh

join:
	./scripts/join-channel.sh

deploy:
	./scripts/deploy-chaincode.sh

clean:
	docker-compose -f docker-compose-network.yaml down
	docker-compose -f docker-compose-ca.yaml down
	rm -f talent-chaincode.tar.gz
	git clean -fd
	find . -type d -empty -delete
