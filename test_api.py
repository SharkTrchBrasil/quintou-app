import requests

base_url = "https://ifo1usk4zzs6kf3w1axrg1y9.207.180.251.156.sslip.io"

def test_endpoint(path):
    url = f"{base_url}{path}"
    try:
        response = requests.get(url)
        print(f"{path}: {response.status_code} - {response.text[:100]}")
    except Exception as e:
        print(f"{path}: ERROR - {str(e)}")

print("Testing remote API endpoints:")
test_endpoint("/docs")
test_endpoint("/spaces")
test_endpoint("/spaces/my")
test_endpoint("/chat/conversations")
