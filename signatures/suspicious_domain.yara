rule pv204_suspicious_domain {
  meta:
    description = "Detects mialepromo.ru C2 domain in process memory or binaries"
    author = "Vasek Lorenc"
    date = "2020-04-29"
    reference = "PV204 exercise01"
  strings:
    $domain = "mialepromo.ru" ascii wide nocase
  condition:
    $domain
}

rule pv204_suspicious_agent {
  meta:
    description = "Detects Our_Agent malware User-Agent header"
    author = "Vasek Lorenc"
    date = "2020-04-29"
    reference = "PV204 exercise01"
  strings:
    $ua = "Our_Agent" ascii wide nocase
  condition:
    $ua
}
