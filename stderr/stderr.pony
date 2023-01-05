actor Main
    new create(env: Env) =>
        env.out.print("This is an output sent to STDOUT\n")
        env.err.print("This is an output sent to STDERR\n")