#!/usr/bin/env nextflow

process sayHello {
  input: 
    val x
  output:
    stdout
  script:
    """
    echo '$x world!'
    sleep 50
    """
}

workflow {
  Channel.of(
    'Bonjour', 'Ciao', 'Hello', 'Hola', 'Guten Tag', 'Konnichiwa', 'Namaste', 'Shalom',
    'Salaam', 'Zdravstvuyte', 'Ni Hao', 'Annyeonghaseyo', 'Sawadee', 'Jambo', 'Aloha',
    'Howdy', 'Ahoy', 'Salve', 'Hej', 'Merhaba', 'Sveiki', 'Hallo', 'Kumusta',
    'Sawasdee', 'Dobry Den', 'Bom Dia', 'Buenos Dias', 'Buongiorno', 'Goedemorgen',
    'God Morgen', 'Kali Mera', 'Selamat Pagi', 'Ohayo', 'Zao Shang Hao', 'Suprabhat',
    'Subah Bakhair', 'Sabah Al-khayr', 'Boker Tov', 'Dobroe Utro'
  ) | sayHello | view
}
