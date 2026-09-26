#!/usr/bin/env python3
import http.server
import ssl
import urllib.request
import json
import os
import sys

BACKEND = "http://127.0.0.1:5000"
CERT_PATH = os.environ.get("PROXY_CERT", os.path.expanduser("~/.local/share/tclient-proxy/cert.pem"))
KEY_PATH = os.environ.get("PROXY_KEY", os.path.expanduser("~/.local/share/tclient-proxy/key.pem"))
PORT = int(os.environ.get("PROXY_PORT", "5001"))

LANGUAGE_LOOKUP = {
    # Turkish
    "turkish": "tr", "türkisch": "tr", "turkce": "tr", "türkçe": "tr", "tr": "tr",
    # German
    "german": "de", "deutsch": "de", "de": "de",
    # English
    "english": "en", "englisch": "en", "en": "en",
    # Russian
    "russian": "ru", "russisch": "ru", "ru": "ru",
    # French
    "french": "fr", "französisch": "fr", "francais": "fr", "française": "fr", "fr": "fr",
    # Spanish
    "spanish": "es", "spanisch": "es", "espanol": "es", "español": "es", "es": "es",
    # Polish
    "polish": "pl", "polnisch": "pl", "polski": "pl", "pl": "pl",
    # Ukrainian
    "ukrainian": "uk", "ukrainisch": "uk", "uk": "uk",
    # Italian
    "italian": "it", "italienisch": "it", "italiano": "it", "it": "it",
    # Chinese
    "chinese": "zh", "chinesisch": "zh", "zh": "zh",
    # Japanese
    "japanese": "ja", "japanisch": "ja", "ja": "ja",
    # Arabic
    "arabic": "ar", "arabisch": "ar", "ar": "ar",
    # Portuguese
    "portuguese": "pt", "portugiesisch": "pt", "português": "pt", "pt": "pt",
    # Dutch
    "dutch": "nl", "niederländisch": "nl", "nl": "nl",
    # Swedish
    "swedish": "sv", "schwedisch": "sv", "sv": "sv",
    # Greek
    "greek": "el", "griechisch": "el", "el": "el",
    # Czech
    "czech": "cs", "tschechisch": "cs", "cs": "cs",
    # Finnish
    "finnish": "fi", "finnisch": "fi", "fi": "fi",
    # Danish
    "danish": "da", "dänisch": "da", "da": "da",
    # Norwegian
    "norwegian": "no", "norwegisch": "no", "no": "no",
    # Romanian
    "romanian": "ro", "rumänisch": "ro", "ro": "ro",
    # Hungarian
    "hungarian": "hu", "ungarisch": "hu", "hu": "hu",
}

def extract_language_prefix(text):
    text = text.strip()
    if ":" in text:
        prefix, rest = text.split(":", 1)
        prefix = prefix.strip().lower()
        rest = rest.strip()
        if (rest.startswith('"') and rest.endswith('"')) or (rest.startswith("'") and rest.endswith("'")):
            rest = rest[1:-1].strip()
        if prefix in LANGUAGE_LOOKUP and rest:
            return LANGUAGE_LOOKUP[prefix], rest
    return None, text

def is_german(text):
    try:
        detect_req = urllib.request.Request(
            f"{BACKEND}/detect",
            data=json.dumps({"q": text}).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST"
        )
        with urllib.request.urlopen(detect_req, timeout=3) as resp:
            data = json.loads(resp.read().decode("utf-8"))
            if data and isinstance(data, list) and len(data) > 0:
                lang = data[0].get("language")
                confidence = data[0].get("confidence", 0)
                if lang == "de" and confidence >= 50.0:
                    return True
    except Exception:
        pass
    return False

class ProxyHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        content_len = int(self.headers.get("Content-Length", 0))
        body_bytes = self.rfile.read(content_len)

        # Check if this is a translation request
        if self.path.rstrip("/") == "/translate":
            try:
                payload = json.loads(body_bytes.decode("utf-8"))
                source_lang = payload.get("source", "auto")
                target_lang = payload.get("target", "en")
                text = payload.get("q", "")
                sys.stderr.write(f"[PROXY] /translate req: q={text!r}, target={target_lang}, source={source_lang}\n")
                sys.stderr.flush()

                # 1. Check for language prefix like 'turkish: message' or 'tr: message'
                target_override, cleaned_text = extract_language_prefix(text)
                if target_override:
                    sys.stderr.write(f"[PROXY] Prefix matched -> target: {target_override}, text: {cleaned_text!r}\n")
                    sys.stderr.flush()
                    req_data = json.dumps({
                        "q": cleaned_text,
                        "source": "auto",
                        "target": target_override,
                        "format": payload.get("format", "text")
                    }).encode("utf-8")
                    req = urllib.request.Request(
                        f"{BACKEND}/translate",
                        data=req_data,
                        headers={"Content-Type": "application/json"},
                        method="POST"
                    )
                    with urllib.request.urlopen(req, timeout=10) as resp:
                        resp_bytes = resp.read()
                        sys.stderr.write(f"[PROXY] LibreTranslate returned: {resp_bytes.decode('utf-8', 'ignore')}\n")
                        sys.stderr.flush()
                        self.send_response(resp.status)
                        for k, v in resp.headers.items():
                            if k.lower() not in ("content-length", "transfer-encoding"):
                                self.send_header(k, v)
                        self.send_header("Content-Length", str(len(resp_bytes)))
                        self.end_headers()
                        self.wfile.write(resp_bytes)
                        return

                # 2. If target is 'en' and text is German, return original text untouched
                if target_lang == "en" and (source_lang == "de" or (source_lang == "auto" and is_german(text))):
                    sys.stderr.write(f"[PROXY] German detected -> keeping untouched: {text!r}\n")
                    sys.stderr.flush()
                    res_body = json.dumps({
                        "translatedText": text,
                        "detectedLanguage": {"confidence": 100.0, "language": "de"}
                    }).encode("utf-8")
                    self.send_response(200)
                    self.send_header("Content-Type", "application/json")
                    self.send_header("Content-Length", str(len(res_body)))
                    self.end_headers()
                    self.wfile.write(res_body)
                    return
            except Exception as e:
                sys.stderr.write(f"[PROXY] Error in do_POST /translate: {e}\n")
                sys.stderr.flush()

        # Otherwise, forward request to LibreTranslate backend
        target_url = BACKEND + self.path
        req = urllib.request.Request(
            target_url,
            data=body_bytes,
            headers={k: v for k, v in self.headers.items() if k.lower() != "host"},
            method="POST"
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                resp_bytes = resp.read()
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in ("content-length", "transfer-encoding"):
                        self.send_header(k, v)
                self.send_header("Content-Length", str(len(resp_bytes)))
                self.end_headers()
                self.wfile.write(resp_bytes)
        except urllib.error.HTTPError as e:
            err_bytes = e.read()
            self.send_response(e.code)
            for k, v in e.headers.items():
                if k.lower() not in ("content-length", "transfer-encoding"):
                    self.send_header(k, v)
            self.send_header("Content-Length", str(len(err_bytes)))
            self.end_headers()
            self.wfile.write(err_bytes)
        except Exception as e:
            err_msg = json.dumps({"error": str(e)}).encode("utf-8")
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(err_msg)))
            self.end_headers()
            self.wfile.write(err_msg)

    def do_GET(self):
        target_url = BACKEND + self.path
        req = urllib.request.Request(
            target_url,
            headers={k: v for k, v in self.headers.items() if k.lower() != "host"},
            method="GET"
        )
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                resp_bytes = resp.read()
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in ("content-length", "transfer-encoding"):
                        self.send_header(k, v)
                self.send_header("Content-Length", str(len(resp_bytes)))
                self.end_headers()
                self.wfile.write(resp_bytes)
        except urllib.error.HTTPError as e:
            err_bytes = e.read()
            self.send_response(e.code)
            for k, v in e.headers.items():
                if k.lower() not in ("content-length", "transfer-encoding"):
                    self.send_header(k, v)
            self.send_header("Content-Length", str(len(err_bytes)))
            self.end_headers()
            self.wfile.write(err_bytes)

    def log_message(self, format, *args):
        pass

def run():
    server = http.server.HTTPServer(("127.0.0.1", PORT), ProxyHandler)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain(certfile=CERT_PATH, keyfile=KEY_PATH)
    server.socket = context.wrap_socket(server.socket, server_side=True)
    server.serve_forever()

if __name__ == "__main__":
    run()
