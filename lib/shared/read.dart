enum ReadSource { remote, cache }

class Read<T> {
  const Read(this.data, {required this.source});

  final T data;
  final ReadSource source;
}
