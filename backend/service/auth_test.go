package service

import (
	"context"
	"fmt"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/google/go-cmp/cmp"
	"path/filepath"
	"regexp"
	"testing"
	"time"
)

func authNow() time.Time {
	return time.UnixMilli(1633104919718)
}

func TestAuthMessage(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "auth"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				msg, e := impl.GetAuthMessage(context.Background(), addresses[5])
				if e != nil {
					t.Errorf("get auth message failed: %+v", e)
					return
				}
				if !regexp.MustCompile(fmt.Sprintf("^Hello, %s! Please, sign this message with random "+
					"param [0-9]{10} to use MinterGuru application!$", addresses[5])).MatchString(msg.Message) {
					t.Errorf("auth message unmatch: %s", msg)
				}
			})
		})
	})
}

func TestAuthMessageReplace(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "auth"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				msg, e := impl.GetAuthMessage(context.Background(), addresses[1])
				if e != nil {
					t.Errorf("get auth message with replace failed: %+v", e)
					return
				}
				if !regexp.MustCompile(fmt.Sprintf("^Hello, %s! Please, sign this message with random "+
					"param [0-9]{10} to use MinterGuru application!$", addresses[1])).MatchString(msg.Message) {
					t.Errorf("auth message unmatch: %s", msg)
				}
			})
		})
	})
}

func TestAuthWithSignature(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "auth"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				key, err := crypto.HexToECDSA(privateKeys[1])
				if err != nil {
					t.Errorf("parse key failed: %s", err)
					return
				}
				hash := crypto.Keccak256([]byte("\x19Ethereum Signed Message:\n136Hello, 0x7c342c036160c749d1b43192e98b4776854be2c4! " +
					"Please, sign this message with random param 1603204000 to use MinterGuru application!"))
				sig, err := crypto.Sign(hash, key)
				if err != nil {
					t.Errorf("sign failed: %s", err)
					return
				}
				authResp, e := impl.Auth(context.Background(), addresses[1], common.Bytes2Hex(sig))
				if e != nil {
					t.Errorf("auth failed: %+v", e)
					return
				}
				if d := cmp.Diff(authResp, &AuthResponse{
					User: &User{
						Address: addresses[1],
						Id:      1,
					},
					AccessToken: authResp.AccessToken,
				}); d != "" {
					t.Errorf("auth res unmatch: %s", d)
					return
				}
			})
		})
	})
}

func TestAuthWithSignatureNewClient(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "auth"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				key, err := crypto.HexToECDSA(privateKeys[3])
				if err != nil {
					t.Errorf("parse key failed: %s", err)
					return
				}
				hash := crypto.Keccak256([]byte("\x19Ethereum Signed Message:\n136Hello, 0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1! " +
					"Please, sign this message with random param 1603274000 to use MinterGuru application!"))
				sig, err := crypto.Sign(hash, key)
				if err != nil {
					t.Errorf("sign failed: %s", err)
					return
				}
				authResp, e := impl.Auth(context.Background(), addresses[3], common.Bytes2Hex(sig))
				if e != nil {
					t.Errorf("auth new client failed: %+v", e)
					return
				}
				if d := cmp.Diff(authResp, &AuthResponse{
					User: &User{
						Address: addresses[3],
						Id:      2,
					},
					AccessToken: authResp.AccessToken,
				}); d != "" {
					t.Errorf("auth new client res unmatch: %s", d)
					return
				}
			})
		})
	})
}

func testAuthCodeNotExist(impl *MinterGuruServiceImpl) func(t *testing.T) {
	return func(t *testing.T) {
		key, err := crypto.HexToECDSA(privateKeys[4])
		if err != nil {
			t.Errorf("parse key failed: %s", err)
			return
		}
		hash := crypto.Keccak256([]byte("Hello, 0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1! " +
			"Please, sign this message with random param 1603274000 to use MinterGuru application!"))
		sig, err := crypto.Sign(hash, key)
		if err != nil {
			t.Errorf("sign failed: %s", err)
			return
		}
		res, e := impl.Auth(context.Background(), addresses[4], common.Bytes2Hex(sig))
		if res != nil {
			t.Errorf("auth code not exist res is not empty: %+v", res)
			return
		}
		if d := cmp.Diff(e, CodeNotFound); d != "" {
			t.Errorf("auth code not exist error unmatch: %s", d)
			return
		}
	}
}

func testAuthCodeExpired(impl *MinterGuruServiceImpl) func(t *testing.T) {
	return func(t *testing.T) {
		key, err := crypto.HexToECDSA(privateKeys[4])
		if err != nil {
			t.Errorf("parse key failed: %s", err)
			return
		}
		hash := crypto.Keccak256([]byte("Hello, 0x1f091e0cfa49eddfc7b3e2fc8762c9cf0c6aefe1! " +
			"Please, sign this message with random param 1603274000 to use MinterGuru application!"))
		sig, err := crypto.Sign(hash, key)
		if err != nil {
			t.Errorf("sign failed: %s", err)
			return
		}
		res, e := impl.Auth(context.Background(), addresses[2], common.Bytes2Hex(sig))
		if res != nil {
			t.Errorf("auth code expired res is not empty: %+v", res)
			return
		}
		if d := cmp.Diff(e, CodeExpired); d != "" {
			t.Errorf("auth code expired error unmatch: %s", d)
			return
		}
	}
}

func testAuthWrongSignature(impl *MinterGuruServiceImpl) func(t *testing.T) {
	return func(t *testing.T) {
		key, err := crypto.HexToECDSA(privateKeys[2])
		if err != nil {
			t.Errorf("parse key failed: %s", err)
			return
		}
		hash := crypto.Keccak256([]byte("\x19Ethereum Signed Message:\n136Hello, 0x7c342c036160c749d1b43192e98b4776854be2c4! " +
			"Please, sign this message with random param 1603204000 to use MinterGuru application!"))
		sig, err := crypto.Sign(hash, key)
		if err != nil {
			t.Errorf("sign failed: %s", err)
			return
		}
		res, e := impl.Auth(context.Background(), addresses[1], common.Bytes2Hex(sig))
		if res != nil {
			t.Errorf("auth wrong signature res is not empty: %+v", res)
			return
		}
		if d := cmp.Diff(e, WrongSignature); d != "" {
			t.Errorf("auth wrong siganture error unmatch: %s", d)
			return
		}
	}
}

func TestAuthErrors(t *testing.T) {
	NowWrap(t, authNow, func(t *testing.T) {
		GooseWrap(t, filepath.Join("tests", "auth"), func(t *testing.T) {
			ServiceWrap(t, func(t *testing.T, impl *MinterGuruServiceImpl) {
				t.Run("TestAuthCodeNotExist", testAuthCodeNotExist(impl))
				t.Run("TestAuthCodeExpired", testAuthCodeExpired(impl))
				t.Run("TestAuthWrongSignature", testAuthWrongSignature(impl))
			})
		})
	})
}
