const TAG_CORE = 'NamTranDev';

void logger(Object? object, {String? tag}) {
  try {
    StringBuffer log = StringBuffer(tag == null ? '' : '$tag : ');
    log.write(object);
    log.write(" ");
    log.write(StackTrace.fromString(getLine(StackTrace.current)));
    print(log);
    getLine(StackTrace.current).split("(");
  // ignore: empty_catches
  } catch (e) {}
}

String getLine(StackTrace trace) {
  return trace.toString().split("\n")[1].split("(")[1].split(")")[0];
}
