postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres

createdb:
	docker exec -it postgres createdb --username=root --owner=root simple_bank

dropdb:
	docker exec -it postgres dropdb --username=root --owner=root simple_bank

migrateup:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose up

migratedown:
	migrate -source=file://db/migration -database "postgres://root:secret@localhost:5432/simple_bank?sslmode=disable" -verbose down

sqlc:
	docker run --rm -v "$(CURDIR):/src" -w /src kjconroy/sqlc generate

test:
	PATH=/snap/bin go test -v -cover ./... 2>/dev/null

testCI: 
	go test -v -cover ./...

.PHONY: createdb dropdb postgres migrateup migratedown test testCI

