package logic

import (
	"context"

	"template/internal/svc"
	"template/internal/types"

	"github.com/fengde/gocommon/logx"
)

type HelloLogic struct {
	ctx    context.Context
	svcCtx *svc.ServiceContext
}

func NewHelloLogic(ctx context.Context, svcCtx *svc.ServiceContext) HelloLogic {
	return HelloLogic{
		ctx:    ctx,
		svcCtx: svcCtx,
	}
}

func (l *HelloLogic) Hello(req types.HelloRequest) (*types.HelloResponse, error) {
	// todo: add your logic here and delete this line
	logx.Debug("hello")
	return &types.HelloResponse{}, nil
}
