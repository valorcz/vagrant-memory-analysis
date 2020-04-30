rule pv204_suspicious_domain {
  meta:
    description =  "Detects our very suspicious domain"
    author = "Vasek Lorenc"
    date = "2020-04-29"
  strings:
    $env1 = /mialepromo.ru/
  condition:
    any of them
}

rule pv204_suspicious_agent {
  meta:
    description =  "Detects our very suspicious agent"
    author = "Vasek Lorenc"
    date = "2020-04-29"
  strings:
    $env1 = /Our_Agent/
  condition:
    any of them
}

