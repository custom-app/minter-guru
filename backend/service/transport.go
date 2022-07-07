package service

import (
	"context"
	"encoding/json"
	"github.com/go-kit/kit/endpoint"
	"net/http"
)

type AuthMessageRequest struct {
	Address string `json:"address"`
}

type AuthMessageResponse struct {
	Message string `json:"message"`
}

type AuthRequest struct {
	Address   string `json:"address"`
	Signature string `json:"signature"`
}

type AuthResponse struct {
	User        *User      `json:"user"`
	AccessToken *TokenData `json:"accessToken"`
}

type FaucetRecordsResponse struct {
	Records []*FaucetRecord `json:"records"`
}

type FaucetResponse struct {
	Record *FaucetRecord `json:"record"`
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
		res, e := s.Auth(ctx, req.Address, req.Signature)
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeGetFaucetRecordsEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, _ interface{}) (response interface{}, err error) {
		res, e := s.GetFaucetRecords(ctx, ctx.Value("userId").(int64))
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}

func makeFaucetEndpoint(s MinterGuruService) endpoint.Endpoint {
	return func(ctx context.Context, _ interface{}) (response interface{}, err error) {
		res, e := s.Faucet(ctx, ctx.Value("userId").(int64))
		if e != nil {
			return e, nil
		}
		return res, nil
	}
}
