

use "files"
use "process"
use "backpressure"

actor Main
    new create(env: Env) =>
        let file_path: String iso = "/Users/jairocaro-accinoviciana/pony-lsp/bug".clone()
        let client = Notifier(env)
        let notifier: ProcessNotify iso = consume client
        let binpath = FilePath(FileAuth(env.root), "/Users/jairocaro-accinoviciana/.local/share/ponyup/bin/ponyc")
        let sp_auth = StartProcessAuth(env.root)
        let bp_auth = ApplyReleaseBackpressureAuth(env.root)
        let args: Array[String] val = recover val 
            let a = ["--astpackage"; "--pass=final"; "-V=0"]
            a.>push(consume file_path)
          end
        env.out.write(binpath.path)
        for a in args.values() do
            env.out.write(" " + a)
        end
        env.out.print("\n")
        let pm: ProcessMonitor = ProcessMonitor(sp_auth, bp_auth, consume notifier,
          binpath, args, [])
        pm.done_writing()

class Notifier is ProcessNotify
  let env: Env

  new iso create(env': Env) =>
    env = env'

  fun ref stdout(process: ProcessMonitor ref, data: Array[U8] iso) =>
    let out = String.from_array(consume data)
    env.out.write(out)

  fun ref stderr(process: ProcessMonitor ref, data: Array[U8] iso) =>
    let err = String.from_array(consume data)
    env.out.write(err)

  fun ref failed(process: ProcessMonitor ref, err: ProcessError) =>
    env.out.print("FAILED: " + err.string())

  fun ref dispose(process: ProcessMonitor ref, child_exit_status: ProcessExitStatus) =>
    match child_exit_status
    | let exited: Exited =>
      env.out.print("Child exit code: " + exited.exit_code().string())
    | let signaled: Signaled =>
      env.out.print("Child terminated by signal: " + signaled.signal().string())
    end