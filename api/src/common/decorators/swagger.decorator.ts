import { applyDecorators } from '@nestjs/common';
import { ApiResponse } from '@nestjs/swagger';

export function SwaggerDefaultResponses(correct = 200) {
  return applyDecorators(
    ApiResponse({ status: correct, description: 'Ok' }),
    ApiResponse({
      status: 400,
      description: 'Bad request. Property incorrect.',
      schema: {
        example: {
          statusCode: 400,
          message: ['property incorrect'],
          error: 'Bad Request',
        },
      },
    }),
    ApiResponse({
      status: 401,
      description: 'Unauthorized. Bearer token is missing or invalid.',
      schema: {
        example: {
          statusCode: 401,
          message: 'Invalid credentials',
          error: 'Unauthorized',
        },
      },
    }),
  );
}
