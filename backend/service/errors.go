package service

var (
	ParseFailed = &ErrorResponse{
		Code:    400,
		Message: "parse failed",
		Detail:  "",
	}
	InternalError = &ErrorResponse{
		Code:    500,
		Message: "internal error",
		Detail:  "",
	}
)
