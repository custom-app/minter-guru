package service

import (
	"context"
	"encoding/json"
	"github.com/go-kit/kit/endpoint"
	"net/http"
	"regexp"
	"time"
)

var addressRegExp = regexp.MustCompile("^0x[a-fA-F\\d]{40}$")

type TokenData struct {
	Token     string `json:"token"`
	ExpiresAt int64  `json:"expiresAt"`
}

type User struct {
	Address string `json:"address"`
	Id      int64  `json:"id"`
}

type Transaction struct {
	Id string `json:"id"`
}

type TwitterReward struct {
	Id          int64        `json:"id"`
	CreatedAt   int64        `json:"createdAt"`
	Transaction *Transaction `json:"transaction"`
}

type AuthMessageRequest struct {
	Address string `json:"address"`
}

func (a *AuthMessageRequest) Validate() *ErrorResponse {
	if !addressRegExp.MatchString(a.Address) {
		return WithDetail(ValidationFailed, "address")
	}
	return nil
}

type AuthMessageResponse struct {
	Message string `json:"message"`
}

type AuthRequest struct {
	Address   string `json:"address"`
	Signature string `json:"signature"`
}

func (a *AuthRequest) Validate() *ErrorResponse {
	if !addressRegExp.MatchString(a.Address) {
		return WithDetail(ValidationFailed, "address")
	}
	if len(a.Signature) < 1 {
		return WithDetail(ValidationFailed, "signature")
	}
	return nil
}

type AuthResponse struct {
	User        *User      `json:"user"`
	AccessToken *TokenData `json:"accessToken"`
}

type FaucetByAddressRequest struct {
	Address string `json:"address"`
}

type TwitterRewardsByAddressRequest struct {
	Address string `json:"address"`
}

type TwitterRewardsResponse struct {
	Records []*TwitterReward `json:"records"`
}

type ApplyForTwitterRewardByAddressRequest struct {
	Address string `json:"address"`
}

type ApplyForTwitterRewardResponse struct {
	Record *TwitterReward `json:"record"`
}

type ErrorResponse struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Detail  string `json:"detail"`
}

func decodeAuthMessageRequest(_ context.Context, r *http.Request) (interface{}, error) {
	var req AuthMessageRequest
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return nil, err
	}
	return &req, nil
}

func decodeAuthRequest(_ context.Context, r *http.Request) (interface{}, error) {
	var req AuthRequest
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return nil, err
	}
	return &req, nil
}

func decodeFaucetByAddressRequest(_ context.Context, r *http.Request) (interface{}, error) {
	var req FaucetByAddressRequest
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return nil, err
	}
	return &req, nil
}

func decodeApplyForTwitterByAddressRequest(_ context.Context, r *http.Request) (interface{}, error) {
	var req ApplyForTwitterRewardByAddressRequest
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return nil, err
	}
	return &req, nil
}

func decodeGetTwitterRewardsByAddressRequest(_ context.Context, r *http.Request) (interface{}, error) {
	var req TwitterRewardsByAddressRequest
	defer r.Body.Close()
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return nil, err
	}
	return &req, nil
}

func decodeEmptyRequest(_ context.Context, r *http.Request) (interface{}, error) {
	return nil, nil
}

func encodeResponse(_ context.Context, w http.ResponseWriter, response interface{}) error {
	e, ok := response.(*ErrorResponse)
	if ok {
		w.WriteHeader(e.Code)
		return json.NewEncoder(w).Encode(response)
	}
	return json.NewEncoder(w).Encode(response)
}

func makeAuthMessageEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		req, ok := request.(*AuthMessageRequest)
		if !ok {
			return ParseFailed, nil
		}
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.GetAuthMessage(ctx, req.Address)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeAuthEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		req, ok := request.(*AuthRequest)
		if !ok {
			return ParseFailed, nil
		}
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.Auth(ctx, req.Address, req.Signature)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeGetTwitterRewardsEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, _ interface{}) (response interface{}, err error) {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.GetTwitterRewards(ctx, ctx.Value("userId").(int64))
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeGetTwitterRewardsByAddressEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req, ok := request.(*TwitterRewardsByAddressRequest)
		if !ok {
			return ParseFailed, nil
		}
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.GetTwitterRewardsByAddress(ctx, req.Address)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeApplyForTwitterRewardEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, _ interface{}) (response interface{}, err error) {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.ApplyForTwitterReward(ctx, ctx.Value("userId").(int64))
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeApplyForTwitterRewardByAddressEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req, ok := request.(*ApplyForTwitterRewardByAddressRequest)
		if !ok {
			return ParseFailed, nil
		}
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.ApplyForTwitterRewardByAddress(ctx, req.Address)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeFaucetEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, _ interface{}) (response interface{}, err error) {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.Faucet(ctx, ctx.Value("userId").(int64))
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeFaucetByAddressEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (response interface{}, err error) {
		req, ok := request.(*FaucetByAddressRequest)
		if !ok {
			return ParseFailed, nil
		}
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()
		res, e := s.FaucetByAddress(ctx, req.Address)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}
