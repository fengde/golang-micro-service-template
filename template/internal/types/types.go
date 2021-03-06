// Code generated by goctl. DO NOT EDIT.
package types

type Request struct {
}

type Response struct {
	Code      int64       `json:"code"`
	Message   string      `json:"message"`
	Data      interface{} `json:"data"`
	RequestID string      `json:"request_id"`
}

type HelloRequest struct {
	Name string `path:"name,options=you|me"`
}

type HelloData struct {
	Message string `json:"message"`
}

type HelloResponse struct {
	Response
	Data HelloData `json:"data"`
}
