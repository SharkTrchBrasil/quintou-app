import requests

base_url = "https://ifo1usk4zzs6kf3w1axrg1y9.207.180.251.156.sslip.io"

def login():
    res = requests.post(f"{base_url}/auth/login", data={
        "username": "csa@csa.com",  # Just guessing an email
        "password": "password"
    })
    return res

print(login().text)
