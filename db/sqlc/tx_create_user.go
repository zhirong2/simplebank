package db

import "context"

type CreateUserTxParams struct {
	CreateUserParams
	AfterCreate func(user User) error // This function will be executed in the same tx and will be used
	// to be decide if the transaction should be commited or not.
}

type CreateUserTxResult struct {
	
}

// Transfer Tx performs a money transfer from one account to the other
// It creates a transfer record, add account entries, and update accounts' balance within a single database transaction
func (store *SQLStore) CreateUserTx(ctx context.Context, arg CreateUserTxParams) (CreateUserTxResult, error) {
	var result CreateUserTxResult

	err := store.execTx(ctx, func(q *Queries) error {
		var err error

		q.CreateUser(ctx, arg.CreateUserParams)

		return err
	})

	return result, err
}

