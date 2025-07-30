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
    """
}

workflow {
  Channel.of('Bonjour', 'Ciao', 'Hello', 'Hola') | sayHello | view
}
