package service

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"github.com/custom-app/minter-guru/backend/contracts/migu_token"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/accounts/abi/bind/backends"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/jackc/pgx/v4"
	"github.com/jackc/pgx/v4/pgxpool"
	_ "github.com/jackc/pgx/v4/stdlib"
	"github.com/pressly/goose"
	"log"
	"math/big"
	"os"
	"path/filepath"
	"testing"
	"time"
)

type EmptyGooseLogger struct {
}

func (e *EmptyGooseLogger) Fatal(v ...interface{}) {
	log.Fatal(v...)
}
func (e *EmptyGooseLogger) Fatalf(format string, v ...interface{}) {
	log.Fatalf(format, v...)
}
func (e *EmptyGooseLogger) Print(v ...interface{}) {

}
func (e *EmptyGooseLogger) Println(v ...interface{}) {

}
func (e *EmptyGooseLogger) Printf(format string, v ...interface{}) {

}

const (
	deployerPrivateKey          = "4b11948482dd58d5a79511d4ba14c66f8109d96876b66d6e68ee97f76025402a"
	deployerAddress             = "0x347bBcaAdFAa5567CfFB5E47D690aB0367570b5D"
	gamingRewardAdminPrivateKey = "acc4b11cbdc439dc0ddf1cc63ff54a485d419904721202682a1140843aa05e4c"
	gamingRewardAdminAddress    = "0xc81813BB9639476C24a93A83E296957B986877bB"
	vestingAdminPrivateKey      = "a204adcea68499629a1c0b2ceda380a4d1181dcbb0b8605ff82088a8c60c00f8"
	vestingAdminAddress         = "0xeeec266C8CE72059a93c13399a2697aa22BD646c"
	liquidityAdminPrivateKey    = "c23e5e0bceb1506fb2b99b711b64a2bbf7a336cc4812621ddf7fa45f3aadc356"
	liquidityAdminAddress       = "0x94A97A909CE0EB5F1f470DDa0c9BA54960896602"
	testDatabaseUser            = "minter"
	testDatabasePass            = "1337"
)

var (
	migratePath            string
	cfg                    *Config
	testDatabaseConnString string

	privateKeys = map[int64]string{
		1: "791b12c1dfaebcf1f7cf2e3a12099fa67b3715fb14f70b1cfa03a4ba83108361",
		2: "24b0f6e41cd60af0e093f39cb819b56abee3896cb5298ec0e143d349c73819be",
		3: "879f64ddc23c6b5a3bfd432509dfef14b548dd639c517bfff5c7a56b092a9bc6",
		4: "c41c78e1962ce6a3c9a9417dd978171acbcaa400a5155ba1195540372ecebeaa",
		5: "555a0322579f594265de9a22f8347bf97a94f0ae1d62b4446c05fece1c7e84a4",
	}
	addresses = map[int64]string{
		1: "0x7c342c036160c749d1b43192e98b4776854be2c4",
		2: "0xc9ce728caf6719eadaa772fd0f3ab708b3c37dce",
		3: "0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1",
		4: "0x44dc9cf44534ab8af943d4d6ddf08d6eafaf78b2",
		5: "0x4a8da9fa4b6ad41174b32db9609c900044a73bd6",
	}

	genesis = core.GenesisAlloc{
		common.HexToAddress(deployerAddress): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(gamingRewardAdminAddress): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(vestingAdminAddress): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(liquidityAdminAddress): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(addresses[1]): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(addresses[2]): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(addresses[3]): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(addresses[4]): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
		common.HexToAddress(addresses[5]): {
			Balance: big.NewInt(1e15).Mul(big.NewInt(1e15), big.NewInt(1e15)),
		},
	}
)

func NowWrap(t *testing.T, f func() time.Time, toExec func(*testing.T)) {
	oldNow := nowFunc
	nowFunc = f
	toExec(t)
	nowFunc = oldNow
}

func GooseWrap(t *testing.T, path string, toExec func(t *testing.T)) {
	db, err := sql.Open("pgx", testDatabaseConnString)
	if err != nil {
		t.Errorf("connect to db failed: %s", err)
		return
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Println("close db connection failed:", err)
		}
	}()
	err = goose.Up(db, filepath.Join(migratePath, path))
	if err != nil {
		t.Errorf("up migrations failed: %s", err)
		return
	}
	toExec(t)
	err = goose.Down(db, filepath.Join(migratePath, path))
	if err != nil {
		t.Errorf("down migrations failed: %s", err)
		return
	}
	if err := db.Close(); err != nil {
		t.Errorf("close db connection failed: %s", err)
		return
	}
}

func ServiceWrap(t *testing.T, toExec func(*testing.T, *MinterGuruServiceImpl)) {
	pool, err := pgxpool.Connect(context.Background(), testDatabaseConnString)
	if err != nil {
		t.Errorf("connect to database failed: %s", err)
		return
	}
	impl := &MinterGuruServiceImpl{
		cfg:  cfg,
		pool: pool,
	}
	toExec(t, impl)
	pool.Close()
}

func ServiceWithBlockchainWrap(t *testing.T,
	toExec func(*testing.T, *backends.SimulatedBackend, *MinterGuruServiceImpl)) {
	backend := backends.NewSimulatedBackend(genesis, 1e15)
	pool, err := pgxpool.Connect(context.Background(), testDatabaseConnString)
	if err != nil {
		t.Errorf("connect to database failed: %s", err)
		return
	}
	impl := &MinterGuruServiceImpl{
		cfg:       cfg,
		ethClient: backend,
		pool:      pool,
	}
	toExec(t, backend, impl)
	if err := backend.Close(); err != nil {
		t.Errorf("close backend failed: %s", err)
	}
	pool.Close()
}

func ServiceWithBlockchainAndTokenWrap(t *testing.T,
	toExec func(*testing.T, *backends.SimulatedBackend, *MinterGuruServiceImpl)) {
	backend := backends.NewSimulatedBackend(genesis, 1e15)
	deployerKey, err := crypto.HexToECDSA(deployerPrivateKey)
	if err != nil {
		t.Errorf("failed to parse deployer private key: %s", err)
		return
	}
	deployerOpts, err := bind.NewKeyedTransactorWithChainID(deployerKey, cfg.getChainId())
	if err != nil {
		t.Errorf("failed to build deployer transactor: %s", err)
		return
	}
	multiplier := big.NewInt(0).Exp(big.NewInt(10), big.NewInt(18), nil)
	_, _, tokenInstance, err := migu_token.DeployMinterGuruToken(
		deployerOpts,
		backend,
		big.NewInt(0).Mul(big.NewInt(10000), multiplier),
		big.NewInt(0).Mul(big.NewInt(5000), multiplier),
		big.NewInt(0).Mul(big.NewInt(2000), multiplier),
		big.NewInt(0).Mul(big.NewInt(3000), multiplier),
		common.HexToAddress(liquidityAdminAddress),
		common.HexToAddress(vestingAdminAddress),
		common.HexToAddress(gamingRewardAdminAddress),
	)
	if err != nil {
		t.Errorf("failed to create token instance: %s", err)
		return
	}
	backend.Commit()
	if _, err := tokenInstance.CreateEvent(
		cfg.getMinterGuruTokenGamingRewardTransactor(),
		big.NewInt(100),
		big.NewInt(time.Now().Unix()),
		big.NewInt(time.Now().Add(time.Hour).Unix()),
		[]*big.Int{
			big.NewInt(5000),
			big.NewInt(20000),
		},
		[]*big.Int{
			big.NewInt(1),
			big.NewInt(2),
			big.NewInt(3),
		}); err != nil {
		t.Errorf("failed to create event: %s", err)
		return
	}
	backend.Commit()
	pool, err := pgxpool.Connect(context.Background(), testDatabaseConnString)
	if err != nil {
		t.Errorf("connect to database failed: %s", err)
		return
	}
	impl := &MinterGuruServiceImpl{
		cfg:           cfg,
		ethClient:     backend,
		tokenInstance: tokenInstance,
		pool:          pool,
	}
	toExec(t, backend, impl)
	if err := backend.Close(); err != nil {
		t.Errorf("close backend failed: %s", err)
	}
	pool.Close()
}

func createTestDatabase(connString string) (string, error) {
	now := time.Now().UnixNano() / 1e+6
	rootDb, err := sql.Open("pgx", connString)
	if err != nil {
		return "", err
	}
	defer func() {
		if err := rootDb.Close(); err != nil {
			log.Println("root db close failed: ", err)
		}
	}()
	databaseName := fmt.Sprintf("minter_guru_service_%d", now)
	if _, err := rootDb.Exec(fmt.Sprintf("create database %s", databaseName)); err != nil {
		return "", err
	}
	if _, err := rootDb.Exec(fmt.Sprintf("do $$ BEGIN CREATE USER %s SUPERUSER PASSWORD '%s';"+
		"  EXCEPTION WHEN DUPLICATE_OBJECT THEN RAISE NOTICE 'not creating user'; END $$",
		testDatabaseUser, testDatabasePass)); err != nil {
		return "", err
	}
	if _, err := rootDb.Exec(fmt.Sprintf("GRANT ALL PRIVILEGES ON DATABASE %s TO %s", databaseName, testDatabaseUser)); err != nil {
		return "", err
	}
	return databaseName, nil
}

func dropTestDatabase(connString, databaseName string) error {
	rootDb, err := sql.Open("pgx", connString)
	if err != nil {
		return err
	}
	defer func() {
		if err := rootDb.Close(); err != nil {
			log.Println("root db close failed: ", err)
		}
	}()
	if _, err := rootDb.Exec(fmt.Sprintf("drop database %s", databaseName)); err != nil {
		return err
	}
	return nil
}

func TestMain(m *testing.M) {
	goose.SetLogger(&EmptyGooseLogger{})
	var (
		rootDb  string
		cfgPath string
		err     error
	)
	flag.StringVar(&rootDb, "rootdb", "", "")
	flag.StringVar(&cfgPath, "cfg", "", "")
	flag.StringVar(&migratePath, "migrate", "", "")
	flag.Parse()

	cfg, err = NewConfig(cfgPath)
	if err != nil {
		log.Panicln(err)
	}

	dbCfg, err := pgx.ParseConfig(rootDb)
	if err != nil {
		log.Panicln(err)
	}
	databaseName, err := createTestDatabase(rootDb)
	if err != nil {
		log.Panicln(err)
	}
	testDatabaseConnString = fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		dbCfg.Host, dbCfg.Port, testDatabaseUser, testDatabasePass, databaseName)
	db, err := sql.Open("pgx", testDatabaseConnString)
	if err != nil {
		log.Panicln(err)
	}
	if err := db.Ping(); err != nil {
		log.Panicln(err)
	}
	if err = goose.Up(db, migratePath); err != nil {
		log.Panicln(err)
	}
	code := m.Run()
	if err = goose.Down(db, migratePath); err != nil {
		log.Panicln(err)
	}
	if err := db.Close(); err != nil {
		log.Panicln(err)
	}
	if err := dropTestDatabase(rootDb, databaseName); err != nil {
		log.Panicln(err)
	}
	os.Exit(code)
}
