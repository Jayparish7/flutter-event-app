import 'dart:async';
import 'dart:io';

class ProcessSupervisor {
  final String name;
  final String executable;
  final List<String> args;
  Process? _process;
  StreamSubscription? _stdoutSub;
  StreamSubscription? _stderrSub;

  ProcessSupervisor(this.name, this.executable, this.args);

  Future<void> start() async {
    if (_process != null) {
      print('⚠️ $name is already running');
      return;
    }

    print('🚀 Starting $name: $executable ${args.join(' ')}');

    try {
      _process = await Process.start(
        executable,
        args,
        workingDirectory: Directory.current.path,
        runInShell: true,
      );

      _stdoutSub = _process!.stdout.transform(SystemEncoding().decoder).listen((data) {
        print('[$name][OUT] $data');
      });

      _stderrSub = _process!.stderr.transform(SystemEncoding().decoder).listen((data) {
        print('[$name][ERR] $data');
      });

      _process!.exitCode.then((code) {
        print('❌ $name exited with code $code');
        _process = null;
        _stdoutSub?.cancel();
        _stderrSub?.cancel();
      });
    } catch (e) {
      print('💥 Failed to start $name: $e');
    }
  }

  void stop() {
    _process?.kill();
    _process = null;
  }

  bool get isRunning => _process != null;
}
