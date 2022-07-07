package service

import (
	"context"
	"math/rand"
	"time"
)

func init() {
	rand.Seed(time.Now().UnixNano())
}

func (s *MinterGuruServiceImpl) GetAuthMessage(ctx context.Context, address string) (string, *ErrorResponse) {

}

func (s *MinterGuruServiceImpl) Auth(ctx context.Context, address string, signature string) (*User, *ErrorResponse) {

}
