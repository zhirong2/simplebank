postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb --username=root --owner=root simple_bank

migrateup:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migrateup1:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up 1

migratedown:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

migratedown1:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down 1

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

mock:
	mockgen -destination db/mock/store.go -package mockdb github.com/techschool/simplebank/db/sqlc Store

.PHONY: createdb dropdb postgres migrateup migratedown test testCI server mock sqlcwsl

