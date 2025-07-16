#!/usr/bin/env nextflow

process sayHello {
  memory '0 GB'
  cpus 0
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
