#!/usr/bin/env nextflow

process sayHello {
  memory { x.length() > 4 ? '1 GB' : '512 MB' }
  input: 
    val x
  output:
    stdout
  script:
    """
    echo '$x world!'
    for i in {1..180}; do
        echo "Waiting... \$i/60"
        sleep 5
    done
    """
}

workflow {
  Channel.of('Bonjour', 'Ciao', 'Hello', 'Hola') | sayHello | view
}
