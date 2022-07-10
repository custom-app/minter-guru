package service

import "log"

var (
	ParseFailed = &ErrorResponse{
		Code:    400,
		Message: "parse failed",
		Detail:  "",
	}
	ValidationFailed = &ErrorResponse{
		Code:    400,
		Message: "validation failed",
		Detail:  "",
	}
	CodeNotFound = &ErrorResponse{
		Code:    400,
		Message: "auth message not found",
		Detail:  "",
	}
	CodeExpired = &ErrorResponse{
		Code:    400,
		Message: "auth message expired",
		Detail:  "",
	}
	WrongSignature = &ErrorResponse{
		Code:    400,
		Message: "wrong signature",
		Detail:  "",
	}
	BalanceNonZero = &ErrorResponse{
		Code:    400,
		Message: "balance is not equal to 0",
		Detail:  "",
	}
	AlreadyGotFaucet = &ErrorResponse{
		Code:    400,
		Message: "already got faucet",
		Detail:  "",
	}
	TwitterLimitReached = &ErrorResponse{
		Code:    400,
		Message: "twitter limit reached",
		Detail:  "",
	}
	TwitterEventClosed = &ErrorResponse{
		Code:    400,
		Message: "twitter event closed",
		Detail:  "",
	}
	InternalError = &ErrorResponse{
		Code:    500,
		Message: "internal error",
		Detail:  "",
	}
	ServiceUnavailable = &ErrorResponse{
		Code:    503,
		Message: "service unavailable",
		Detail:  "",
	}
)

func WithDetail(e *ErrorResponse, detail string) *ErrorResponse {
	return &ErrorResponse{
		Code:    e.Code,
		Message: e.Message,
		Detail:  detail,
	}
}

func checkAndLogDatabaseError(err error) *ErrorResponse {
	log.Println("database error", err)
	return InternalError
}
