import {
  ErrorRequestHandler,
  NextFunction,
  Request,
  RequestHandler,
  Response,
} from 'express';
import { AppError, resolveServiceError } from './errors';
import { ApiEnvelope, fail } from './response';

type BodyHandler = (body: unknown) => Promise<ApiEnvelope<unknown>>;

export function createPostHandler(handler: BodyHandler): RequestHandler {
  return async (req: Request, res: Response, next: NextFunction) => {
    try {
      const payload = await handler(req.body);
      res.status(200).json(payload);
    } catch (error) {
      next(error);
    }
  };
}

export const notFoundHandler: RequestHandler = (_req, res) => {
  res.status(404).json(fail('接口不存在(404)，请检查请求路径和后端部署', '404'));
};

export const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  if (error instanceof SyntaxError && 'body' in error) {
    res.status(400).json(fail('请求体不是合法 JSON'));
    return;
  }

  if (error instanceof AppError) {
    res.status(error.status).json(fail(error.message, error.code));
    return;
  }

  console.error('unhandled express error:', error);
  res.status(500).json(fail(resolveServiceError(error)));
};

