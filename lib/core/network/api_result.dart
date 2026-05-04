import '../errors/app_exception.dart';
import '../errors/error_mapper.dart';

sealed class ApiResult<T> {
  const ApiResult();
}

Future<ApiResult<T>> guardApiResult<T>(Future<T> Function() action) async {
  try {
    return ApiSuccess<T>(await action());
  } catch (error) {
    return ApiFailure<T>(mapToAppException(error));
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.error);

  final AppException error;
}
