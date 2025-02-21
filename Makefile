DB_URL=postgres://root:secret@localhost:5432/simple_bank?sslmode=disable

postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb --username=root --owner=root simple_bank

migrateup:
	migrate -source=file://db/migration -database "$(DB_URL)" -verbose up

migrateup1:
	migrate -source=file://db/migration -database "$(DB_URL)" -verbose up 1

migratedown:
	migrate -source=file://db/migration -database "$(DB_URL)" -verbose down

migratedown1:
	migrate -source=file://db/migration -database "$(DB_URL)" -verbose down 1

sqlc:
	docker run --rm -v "/$(shell pwd | sed 's/\\/\//g'):/src" -w /src kjconroy/sqlc generate

sqlcwsl:
	docker run --rm -v "$(CURDIR):/src" -w /src kjconroy/sqlc generate

test:
	go test -v -cover ./... 2>/dev/null

testCI: 
	go test -v -cover ./...

server:
	go run main.go

db_docs:
	dbdocs build doc/db.dbml

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

mock:
	mockgen -destination db/mock/store.go -package mockdb github.com/techschool/simplebank/db/sqlc Store

proto:
	rm -f pb/*.go
	rm -f doc/swagger/*.swagger.json
	protoc --proto_path=proto --go_out=pb --go_opt=paths=source_relative \
	--go-grpc_out=pb --go-grpc_opt=paths=source_relative \
	--grpc-gateway_out=pb --grpc-gateway_opt=paths=source_relative \
	--openapiv2_out=doc/swagger --openapiv2_opt=allow_merge=true,merge_file_name=simple_bank \
	proto/*.proto
	statik -src=./doc/swagger -dest=./doc

redis:
	docker run --name redis -p 6379:6379 -d redis:8.0-M02-alpine

.PHONY: createdb dropdb postgres migrateup migratedown test testCI server mock sqlcwsl db_docs db_schema proto run-evans redis

